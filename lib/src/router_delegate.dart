import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'destination.dart';
import 'navigator.dart';
import 'navigation_scheme.dart';
import 'utils/utils.dart';

/// Implementation of [RouterDelegate].
///
/// Uses [navigationScheme] to build routes.
///
/// See also:
/// - [NavigationScheme]
/// - [TheseusNavigator]
/// - [Destination]
///
class TheseusRouterDelegate extends RouterDelegate<Destination>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  /// Creates router delegate.
  ///
  TheseusRouterDelegate({
    required this.navigationScheme,
  }) {
    Log.d(runtimeType, 'TheseusRouterDelegate():');
    navigationScheme.addListener(_onCurrentDestinationChanged);
  }

  /// A navigation scheme that contains destinations and navigators.
  ///
  /// This router delegate is listening the navigation scheme to identify when the
  /// current destination is changes, and in turn, notifies its listeners when this
  /// happens.
  ///
  final NavigationScheme navigationScheme;

  @override
  GlobalKey<NavigatorState>? get navigatorKey =>
      navigationScheme.findNavigator(navigationScheme.currentDestination)?.key;

  @override
  Widget build(BuildContext context) {
    return navigationScheme.rootNavigator.build(context);
  }

  @override
  Future<bool> popRoute() async {
    Log.d(runtimeType, 'popRoute():');
    navigationScheme.goBack();
    if (navigationScheme.shouldClose) {
      if (Platform.isAndroid) {
        return false;
      } else {
        navigationScheme.goTo(navigationScheme.currentDestination);
        return true;
      }
    }
    return true;
  }

  @override
  // ignore: avoid_renaming_method_parameters
  Future<void> setNewRoutePath(destination) async {
    Log.d(runtimeType, 'setNewRoutePath(): destination=${destination.uri}');
    // Reset current stack when:
    // - the 'upwardDestinationBuilder' is specified, so we should build a custom stack
    // - it is not an 'errorDestination', so we should be able return back to previous destination from the error.
    final reset = (destination.upwardDestinationBuilder != null &&
        destination != navigationScheme.errorDestination);
    return SynchronousFuture(navigationScheme.goTo(destination
        .withConfiguration(destination.configuration.copyWith(reset: reset))));
  }

  @override
  Destination get currentConfiguration => navigationScheme.currentDestination;

  @override
  void dispose() {
    navigationScheme.removeListener(_onCurrentDestinationChanged);
    super.dispose();
  }

  Future<void> _onCurrentDestinationChanged() async {
    final destination = navigationScheme.currentDestination;
    Log.d(runtimeType,
        'onCurrentDestinationChanged(): destination=${destination.uri}');
    // Ignore closing app request here. It is processed in the 'popRoute()' method.
    if (navigationScheme.shouldClose) {
      return;
    }
    // Ignore redirections if we returned back from the redirection
    if (navigationScheme.redirectedFrom == destination) {
      notifyListeners();
      return;
    }
    // Check if the current destination is valid, and perform redirection if needed.
    final isDestinationValid = await navigationScheme.validate();
    Log.d(runtimeType,
        'onCurrentDestinationChanged(): destination=${destination.uri}, isDestinationValid=$isDestinationValid');
    if (!isDestinationValid) {
      return;
    }
    notifyListeners();
  }
}
