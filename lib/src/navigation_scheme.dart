import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'destination.dart';
import 'exceptions.dart';
import 'navigator.dart';
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
/// - [TheseusNavigator]
///
class NavigationScheme with ChangeNotifier {
  /// Creates navigation scheme.
  ///
  NavigationScheme({
    List<Destination> destinations = const <Destination>[],
    this.errorDestination,
    TheseusNavigator? navigator,
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
        TheseusNavigator(
          destinations: <Destination>[
            ...destinations,
            if (errorDestination != null) errorDestination!
          ],
          tag: 'Root',
        );
    _currentDestination = _rootNavigator.currentDestination;
    _initializeNavigator(_rootNavigator);
    _updateCurrentDestination();
  }

  /// The destination to redirect in case of error.
  ///
  final Destination? errorDestination;

  late Destination _currentDestination;

  /// The current destination within the whole navigation scheme.
  ///
  /// To get a current top level destination, use [rootNavigator.currentDestination].
  ///
  Destination get currentDestination => _currentDestination;

  final _navigatorListeners = <TheseusNavigator, VoidCallback?>{};

  final _navigatorMatches = <Destination, TheseusNavigator>{};

  final _navigatorOwners = <TheseusNavigator, Destination>{};

  late final TheseusNavigator _rootNavigator;

  /// The root navigator in the navigation scheme.
  ///
  /// This navigator manages top level destinations.
  ///
  TheseusNavigator get rootNavigator => _rootNavigator;

  Destination? _redirectedFrom;

  /// Stores the original destination in case of redirection.
  ///
  Destination? get redirectedFrom => _redirectedFrom;

  bool _shouldClose = false;

  /// Whether the app should close.
  ///
  /// This flag is set on when user perform 'Back' action on top most destination.
  ///
  bool get shouldClose => _shouldClose;

  @override
  void dispose() {
    _removeNavigatorListeners();
    super.dispose();
  }

  /// Find a destination that match a given URI.
  ///
  /// Returns 'null' if no destination matching the URI was found.
  ///
  Destination? findDestination(String uri) => _navigatorMatches.keys
      .firstWhereOrNull((destination) => destination.isMatch(uri));

  /// Returns a proper navigator in the navigation scheme for a given destination.
  ///
  /// Returns 'null' if no navigator found.
  ///
  TheseusNavigator? findNavigator(Destination destination) =>
      _navigatorMatches[findDestination(destination.path)];

  /// Opens the specified [destination].
  ///
  /// First, searches the navigation scheme for proper navigator for the destination.
  /// If found, uses the navigator's [goTo] method to open the destination.
  /// Otherwise throws [UnknownDestinationException].
  ///
  Future<void> goTo(Destination destination, {bool isRedirection = false}) {
    final navigator = findNavigator(destination);
    if (navigator == null) {
      _handleError(destination);
      return SynchronousFuture(null);
    }
    Log.d(runtimeType,
        'goTo(): navigator=${navigator.tag}, destination=${destination.uri}, isRedirection=$isRedirection');
    _shouldClose = false;
    _redirectedFrom = isRedirection ? _currentDestination : null;
    return SynchronousFuture(navigator.goTo(destination));
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

  /// Validates current destination and perform redirection if needed.
  ///
  Future<bool> validate() async {
    return await _validateDestination(_currentDestination);
  }

  void _initializeNavigator(TheseusNavigator navigator) {
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
      goTo(errorDestination!, isRedirection: true);
    } else {
      throw UnknownDestinationException(destination);
    }
  }

  void _removeNavigatorListeners() {
    for (var navigator in _navigatorListeners.keys) {
      navigator.removeListener(_navigatorListeners[navigator]!);
    }
  }

  void _onNavigatorStateChanged(TheseusNavigator navigator) {
    Log.d(runtimeType,
        'onNavigatorStateChanged(): navigator=${navigator.tag}, error=${navigator.error}, gotBack=${navigator.gotBack}, shouldClose=${navigator.shouldClose}');
    if (navigator.hasError) {
      _handleError(navigator.error!.destination);
    }
    final owner = _navigatorOwners[navigator];
    if (owner != null) {
      Log.d(runtimeType, 'onNavigatorStateChanged(): owner=${owner.uri}');
      if (navigator.gotBack) {
        if (navigator.shouldClose) {
          final parentNavigator = findNavigator(owner);
          if (parentNavigator == null) {
            _handleError(owner);
            return;
          }
          parentNavigator.goBack();
        } else {
          _updateCurrentDestination();
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
      _updateCurrentDestination();
    }
  }

  void _updateCurrentDestination() {
    Destination newDestination = _rootNavigator.currentDestination;
    // TODO: Do we need the stack here?
    List<Destination> newStack = List.from(_rootNavigator.stack);
    if (_rootNavigator.shouldClose) {
      _shouldClose = true;
      Log.d(runtimeType,
          'updateCurrentDestination(): currentDestination=${_currentDestination.uri}, shouldClose=$_shouldClose');
      notifyListeners();
      return;
    } else {
      _shouldClose = false;
      while (!newDestination.isFinalDestination) {
        newStack.addAll(newDestination.navigator!.stack);
        newDestination = newDestination.navigator!.currentDestination;
      }
    }
    if (_currentDestination != newDestination ||
        newDestination.configuration.reset) {
      _currentDestination = newDestination;
      Log.d(runtimeType,
          'updateCurrentDestination(): currentDestination=${_currentDestination.uri}, shouldClose=$_shouldClose');
      notifyListeners();
    }
  }

  Future<bool> _validateDestination(Destination destination) async {
    // Check redirections that are defined for given destination
    for (var redirection in destination.redirections) {
      if (!(await redirection.validate(destination))) {
        goTo(redirection.destination, isRedirection: true);
        return false;
      }
    }
    // In case of nested destination, validate the owner
    final navigator = findNavigator(destination);
    if (navigator == null) {
      _handleError(destination);
      return false;
    }
    final owner = _navigatorOwners[navigator];
    return owner != null ? await _validateDestination(owner) : true;
  }
}
