import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'destination.dart';
import 'exceptions.dart';
import 'navigator.dart';

/// Defines a navigation scheme of the app.
///
/// Contains a list of possible [destinations] to navigate in the app.
/// Each destination can be a final, i.e. is directly rendered as a some screen,
/// or might include a nested navigator with its own destinations.
///
/// Until the custom [navigator] is provided, the NavigatorScheme creates a default
/// root navigator, that manages top level destinations.
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
    TheseusNavigator? navigator,
  }) : assert(
            (destinations.isEmpty ? navigator!.destinations : destinations)
                .any((destination) => destination.isHome),
            'One of destinations must be a home destination.') {
    _rootNavigator = navigator ?? TheseusNavigator(destinations: destinations);
    _currentDestination = _rootNavigator.currentDestination;
    _initializeNavigator(_rootNavigator);
    _updateCurrentDestination();
  }

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
  Destination? findDestination(String uri) => _navigatorMatches.keys
      .firstWhereOrNull((destination) => destination.isMatch(uri));

  /// Finds a proper navigator in the navigation scheme for a given destination.
  ///
  TheseusNavigator? findNavigator(Destination destination) =>
      _navigatorMatches[findDestination(destination.path)];

  /// Close the current destination.
  ///
  /// If the current destination is the last one, this initiates app close by
  /// setting [shouldClose] flag.
  ///
  void goBack() {
    final navigator = findNavigator(_currentDestination);
    if (navigator == null) {
      throw UnknownDestinationException(_currentDestination);
    }
    navigator.goBack();
  }

  /// Opens the specified [destination].
  ///
  /// First, searches the navigation scheme for proper navigator for the destination.
  /// If found, uses the navigator's [goTo] method to open the destination.
  /// Otherwise throws [UnknownDestinationException].
  ///
  void goTo(Destination destination) {
    final navigator = findNavigator(destination);
    if (navigator == null) {
      throw UnknownDestinationException(destination);
    }
    navigator.goTo(destination);
  }

  void _initializeNavigator(TheseusNavigator navigator) {
    listener() => _onNavigatorStackChanged(navigator);

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

  void _removeNavigatorListeners() {
    for (var navigator in _navigatorListeners.keys) {
      navigator.removeListener(_navigatorListeners[navigator]!);
    }
  }

  void _onNavigatorStackChanged(TheseusNavigator navigator) {
    final owner = _navigatorOwners[navigator];
    if (owner != null) {
      goTo(owner);
    } else {
      _updateCurrentDestination();
    }
  }

  void _updateCurrentDestination() {
    Destination newDestination = _rootNavigator.currentDestination;
    // TODO: Do we need the tack here?
    List<Destination> newStack = List.from(_rootNavigator.stack);
    if (_rootNavigator.shouldClose) {
      _shouldClose = true;
    } else {
      var parentNavigator = _rootNavigator;
      while (!newDestination.isFinalDestination) {
        if (newDestination.navigator!.shouldClose) {
          parentNavigator.goBack();
          return;
        }
        newStack.addAll(newDestination.navigator!.stack);
        parentNavigator = newDestination.navigator!;
        newDestination = newDestination.navigator!.currentDestination;
      }
    }
    if (_currentDestination != newDestination || _shouldClose) {
      _currentDestination = newDestination;
      notifyListeners();
    }
  }
}
