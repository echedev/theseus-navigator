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
  NavigationScheme({
    List<Destination> destinations = const <Destination>[],
    TheseusNavigator? navigator,
  }) : assert(
            (destinations.isEmpty ? navigator!.destinations : destinations)
                .any((destination) => destination.isHome),
            'One of destinations must be a home destination.') {
    _rootNavigator = navigator ?? TheseusNavigator(destinations: destinations);
    _currentDestination = _rootNavigator.currentDestination;
    _matchNavigators(_rootNavigator);
    _updateCurrentDestination();
    _addNavigatorListeners();
  }

  late Destination _currentDestination;
  /// The current destination within the whole navigation scheme.
  ///
  /// To get a current top level destination, use [rootNavigator.currentDestination].
  ///
  Destination get currentDestination => _currentDestination;

  final _navigators = <TheseusNavigator>{};

  final _navigatorMatches = <Destination, TheseusNavigator>{};

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

  // TODO: Do we really need the whole stack in the navigation scheme?
  var _stack = <Destination>[];

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
      _navigatorMatches[destination];

  /// Close the current destination.
  ///
  /// If the current destination is the last one, this initiates app close by
  /// setting [shouldClose] flag.
  ///
  Future<void> goBack() {
    final navigator = findNavigator(_currentDestination);
    if (navigator == null) {
      throw UnknownDestinationException(_currentDestination);
    }
    return navigator.goBack();
  }

  /// Opens the specified [destination].
  ///
  /// First, searches the navigation scheme for proper navigator for the destination.
  /// If found, uses the navigator's [goTo] method to open the destination.
  /// Otherwise throws [UnknownDestinationException].
  ///
  Future<void> goTo(Destination destination) async {
    final navigator = findNavigator(destination);
    if (navigator == null) {
      throw UnknownDestinationException(destination);
    }
    return navigator.goTo(destination);
  }

  void _matchNavigators(TheseusNavigator navigator) {
    _navigators.add(navigator);
    for (var destination in navigator.destinations) {
      _navigatorMatches[destination] = navigator;
      if (!destination.isFinalDestination) {
        _matchNavigators(destination.navigator!);
      }
    }
  }

  void _addNavigatorListeners() => _navigators
      .forEach((navigator) => navigator.addListener(_onNavigatorStackChanged));

  void _removeNavigatorListeners() => _navigators.forEach(
      (navigator) => navigator.removeListener(_onNavigatorStackChanged));

  void _onNavigatorStackChanged() {
    _updateCurrentDestination();
  }

  void _updateCurrentDestination() {
    Destination newDestination = _rootNavigator.currentDestination;
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
      _stack = newStack;
      notifyListeners();
    }
  }
}
