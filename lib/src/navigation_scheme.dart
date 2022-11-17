import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'destination.dart';
import 'exceptions.dart';
import 'navigation_controller.dart';
import 'router_delegate.dart';
import 'route_parser.dart';
import 'utils/utils.dart';

/// Defines a navigation scheme of the app.
///
/// Contains a list of possible [destinations] to navigate in the app.
/// Each destination can be a final, i.e. is directly rendered as a some screen,
/// or might include a nested navigator with its own destinations.
///
/// Until the custom [navigator] is provided, the NavigatorScheme creates a default
/// root navigator, that manages top level destinations.
///
/// In case of some navigation error, user will be redirected to [errorDestination],
/// if it is specified. Otherwise an exception will be thrown.
///
/// See also:
/// - [Destination]
/// - [NavigationController]
///
class NavigationScheme with ChangeNotifier {
  /// Creates navigation scheme.
  ///
  NavigationScheme({
    List<Destination> destinations = const <Destination>[],
    this.errorDestination,
    this.waitingOverlayBuilder,
    NavigationController? navigator,
  })  : assert(
            (destinations.isEmpty ? navigator!.destinations : destinations)
                .any((destination) => destination.isHome),
            'One of destinations must be a home destination.'),
        assert(
            errorDestination == null ||
                navigator == null ||
                (navigator.destinations
                    .any((destination) => destination == errorDestination)),
            'When "errorDestination" and custom "navigator" are specified, you must include the "errorDestination" to the "navigator"s destinations') {
    _rootNavigator = navigator ??
        NavigationController(
          destinations: <Destination>[
            ...destinations,
            if (errorDestination != null) errorDestination!,
          ],
          tag: 'Root',
        );
    _routerDelegate = TheseusRouterDelegate(navigationScheme: this);
    _routeParser = TheseusRouteInformationParser(navigationScheme: this);
    _currentDestination = _rootNavigator.currentDestination;
    _initializeNavigator(_rootNavigator);
    _updateCurrentDestination(backFrom: null);
  }

  /// The destination to redirect in case of error.
  ///
  final Destination? errorDestination;

  /// Returns a widget to display while destination is resolving.
  ///
  /// Resolving the destination might be asynchronous, for example, because of parsing typed
  /// parameters or checking redirection conditions.
  ///
  /// In these cases this function is used to build a widget, which would be displayed
  /// until the current destination is resolved.
  ///
  final Widget Function(BuildContext context, Destination destination)?
      waitingOverlayBuilder;

  late Destination _currentDestination;

  /// The current destination within the whole navigation scheme.
  ///
  /// To get a current top level destination, use [rootNavigator.currentDestination].
  ///
  Destination get currentDestination => _currentDestination;

  bool _isResolving = false;

  /// Indicates if a current destination is in resolving state.
  ///
  /// This flag is turned on during performing of the redirection validations, or
  /// parsing of typed parameters.
  ///
  bool get isResolving => _isResolving;

  final _navigatorListeners = <NavigationController, VoidCallback?>{};

  final _navigatorMatches = <Destination, NavigationController>{};

  final _navigatorOwners = <NavigationController, Destination>{};

  final _destinationCompleters = <Destination, Completer<void>>{};

  late final NavigationController _rootNavigator;

  /// The root navigator in the navigation scheme.
  ///
  /// This navigator manages top level destinations.
  ///
  NavigationController get rootNavigator => _rootNavigator;

  late final TheseusRouterDelegate _routerDelegate;

  /// Reference to the RouterDelegate implementation
  ///
  TheseusRouterDelegate get routerDelegate => _routerDelegate;

  late final TheseusRouteInformationParser _routeParser;

  /// Reference to the RouteInformationParser implementation
  ///
  TheseusRouteInformationParser get routeParser => _routeParser;

  /// Stores the original destination in case of redirection.
  ///
  Destination? get redirectedFrom =>
      _currentDestination.configuration.redirectedFrom;

  bool _shouldClose = false;

  /// Whether the app should close.
  ///
  /// This flag is set on when user perform 'Back' action on top most destination.
  ///
  bool get shouldClose => _shouldClose;

  @override
  void dispose() {
    _routerDelegate.dispose();
    _removeNavigatorListeners();
    super.dispose();
  }

  /// Find a destination in the scheme that match a given URI.
  ///
  /// Returns 'null' if no destination matching the URI was found.
  ///
  Destination? findDestination(String uri) => _navigatorMatches.keys
      .firstWhereOrNull((destination) => destination.isMatch(uri));

  /// Returns a proper navigator in the navigation scheme for a given destination.
  ///
  /// Returns 'null' if no navigator found.
  ///
  NavigationController? findNavigator(Destination destination) =>
      _navigatorMatches[findDestination(destination.path)];

  /// Opens the specified [destination].
  ///
  /// First, searches the navigation scheme for proper navigator for the destination.
  /// If found, uses the navigator's [goTo] method to open the destination.
  /// Otherwise throws [UnknownDestinationException].
  ///
  Future<void> goTo(Destination destination) {
    final navigator = findNavigator(destination);
    if (navigator == null) {
      _handleError(destination);
      return SynchronousFuture(null);
    }
    Log.d(runtimeType,
        'goTo(): navigator=${navigator.tag}, destination=$destination, redirectedFrom=${destination.configuration.redirectedFrom}');
    _shouldClose = false;

    final completer = Completer<void>();
    var destinationToComplete = destination;
    _destinationCompleters[destinationToComplete] = completer;
    while (!destinationToComplete.isFinalDestination) {
      destinationToComplete =
          destinationToComplete.navigator!.currentDestination;
      _destinationCompleters[destinationToComplete] = completer;
    }
    navigator.goTo(destination);

    return completer.future;
  }

  /// Close the current destination.
  ///
  /// If the current destination is the last one, this requests closing the app by
  /// setting the [shouldClose] flag.
  ///
  void goBack() {
    final navigator = findNavigator(_currentDestination);
    if (navigator == null) {
      _handleError(_currentDestination);
      return;
    }
    navigator.goBack();
  }

  /// Resolves the current destination
  ///
  /// Applies redirection validations to the current destination.
  /// While validations are performed, the [isResolving] flag is set to true.
  /// This allows to display a widget returned by [waitingOverlayBuilder]
  /// until the destination is resolved.
  ///
  /// In case of validation are not passed, redirects to corresponding redirection destination.
  ///
  Future<void> resolve() async {
    Timer isResolvingTimer = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!_isResolving) {
          _isResolving = true;
          notifyListeners();
        }
      },
    );
    final requestedDestination = _currentDestination;
    final resolvedDestination = await _resolveDestination(requestedDestination);
    isResolvingTimer.cancel();
    Log.d(runtimeType,
        'resolve(): requestedDestination=$requestedDestination, resolvedDestination=$resolvedDestination');
    if (requestedDestination != _currentDestination) {
      _isResolving = false;
      notifyListeners();
      return;
    }
    if (resolvedDestination == requestedDestination) {
      _isResolving = false;
      _completeResolvedDestination(requestedDestination);
      notifyListeners();
      return;
    }
    goTo(resolvedDestination.withConfiguration(resolvedDestination.configuration
        .copyWith(redirectedFrom: requestedDestination)));
  }

  void _initializeNavigator(NavigationController navigator) {
    void listener() => _onNavigatorStateChanged(navigator);

    // Add a listener of the navigator
    _navigatorListeners[navigator] = listener;
    navigator.addListener(listener);

    for (var destination in navigator.destinations) {
      _navigatorMatches[destination] = navigator;
      if (!destination.isFinalDestination) {
        // Set navigation owner
        _navigatorOwners[destination.navigator!] = destination;
        // Initialize nested navigator
        _initializeNavigator(destination.navigator!);
      }
    }
  }

  void _handleError(Destination? destination) {
    if (errorDestination != null) {
      goTo((errorDestination!).withConfiguration(errorDestination!.configuration
          .copyWith(redirectedFrom: destination)));
    } else {
      throw UnknownDestinationException(destination);
    }
  }

  void _removeNavigatorListeners() {
    for (var navigator in _navigatorListeners.keys) {
      navigator.removeListener(_navigatorListeners[navigator]!);
    }
  }

  void _onNavigatorStateChanged(NavigationController navigator) {
    Log.d(runtimeType,
        'onNavigatorStateChanged(): navigator=${navigator.tag}, error=${navigator.error}, backFrom=${navigator.backFrom}, shouldClose=${navigator.shouldClose}');
    if (navigator.hasError) {
      _handleError(navigator.error!.destination);
    }
    final owner = _navigatorOwners[navigator];
    if (owner != null) {
      Log.d(runtimeType, 'onNavigatorStateChanged(): owner=$owner');
      if (navigator.backFrom != null) {
        if (navigator.shouldClose) {
          final parentNavigator = findNavigator(owner);
          if (parentNavigator == null) {
            _handleError(owner);
            return;
          }
          parentNavigator.goBack();
        } else {
          _updateCurrentDestination(backFrom: navigator.backFrom);
        }
      } else {
        if (navigator.currentDestination.configuration.reset) {
          goTo(owner
              .withConfiguration(owner.configuration.copyWith(reset: true)));
        } else {
          goTo(owner);
        }
      }
    } else {
      _updateCurrentDestination(backFrom: navigator.backFrom);
    }
  }

  void _updateCurrentDestination({required Destination? backFrom}) {
    // TODO: Do we need the stack here?
    List<Destination> newStack = List.from(_rootNavigator.stack);
    // TODO: Probably '_shouldClose' variable is not needed, we can use '_rootNavigator' directly
    _shouldClose = _rootNavigator.shouldClose;
    if (_shouldClose) {
      Log.d(runtimeType,
          'updateCurrentDestination(): currentDestination=$_currentDestination, shouldClose=$_shouldClose');
      notifyListeners();
      return;
    }

    Destination newDestination = _rootNavigator.currentDestination;
    while (!newDestination.isFinalDestination) {
      newStack.addAll(newDestination.navigator!.stack);
      newDestination = newDestination.navigator!.currentDestination;
    }
    Log.d(runtimeType,
        'updateCurrentDestination(): currentDestination=$_currentDestination, newDestination=$newDestination');
    if (_currentDestination != newDestination ||
        newDestination.configuration.reset) {
      _currentDestination = newDestination;
      if (_currentDestination == backFrom?.configuration.redirectedFrom) {
        notifyListeners();
        return;
      }
      resolve();
    }
  }

  Future<Destination> _resolveDestination(Destination destination) async {
    // Check redirections that are defined for given destination
    for (var redirection in destination.redirections) {
      if (!(await redirection.validate(destination))) {
        return await _resolveDestination(redirection.destination);
      }
    }
    // In case of nested destination, validate the owner
    final navigator = findNavigator(destination);
    if (navigator == null) {
      throw UnknownDestinationException(destination);
    }
    final owner = _navigatorOwners[navigator];
    if (owner == null) {
      return destination;
    }
    final resolvedOwner = await _resolveDestination(owner);
    return owner != resolvedOwner ? resolvedOwner : destination;
  }

  void _completeResolvedDestination(Destination destination) {
    Destination? destinationToComplete = destination;
    while (destinationToComplete != null) {
      if (!(_destinationCompleters[destinationToComplete]?.isCompleted ??
          true)) {
        _destinationCompleters[destinationToComplete]?.complete();
      }
      destinationToComplete =
          destinationToComplete.configuration.redirectedFrom;
    }
  }
}
