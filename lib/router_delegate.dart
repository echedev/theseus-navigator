import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'destination.dart';
import 'navigator.dart';
import 'navigation_scheme.dart';

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
  TheseusRouterDelegate({
    required this.navigationScheme,
  }) {
    navigationScheme.addListener(_onCurrentDestinationChanged);
  }

  final NavigationScheme navigationScheme;

  @override
  GlobalKey<NavigatorState>? get navigatorKey =>
      navigationScheme.findNavigator(navigationScheme.currentDestination)?.key;

  @override
  Widget build(BuildContext context) {
    return NavigatorBuilder.build(context, navigationScheme.rootNavigator);
  }

  @override
  Future<bool> popRoute() async {
    navigationScheme.goBack();
    return true;
  }

  @override
  Future<void> setNewRoutePath(destination) async {
    navigationScheme.goTo(destination);
  }

  @override
  void dispose() {
    navigationScheme.removeListener(_onCurrentDestinationChanged);
    super.dispose();
  }

  void _onCurrentDestinationChanged() {
    notifyListeners();
  }
}

class NavigatorBuilder {
  static Widget defaultWrapperBuilder(
      BuildContext context, TheseusNavigator navigator) {
    return Navigator(
      key: navigator.key,
      pages: navigator.stack
          .map((destination) => _TheseusPage(
                key: ValueKey(destination.uri),
                destination: destination,
              ))
          .toList(),
      onPopPage: (route, result) {
        navigator.goBack();
        route.didPop(result);
        return true;
      },
    );
  }

  static Widget build(BuildContext context, TheseusNavigator navigator) =>
      navigator.wrapperBuilder == null
          ? NavigatorBuilder.defaultWrapperBuilder(context, navigator)
          : navigator.wrapperBuilder!(
              context, navigator, NavigatorBuilder.build);
}

class _TheseusPage extends Page {
  _TheseusPage({
    required this.destination,
    required LocalKey key,
  }) : super(key: key);

  final Destination destination;

  @override
  Route createRoute(BuildContext context) {
    switch (destination.configuration.transition) {
      case DestinationTransition.material:
        return MaterialPageRoute(
          settings: this,
          builder: (context) => destination.build(context),
        );
      default:
        return PageRouteBuilder(
          settings: this,
          pageBuilder: (context, animation, secondaryAnimation) =>
              destination.build(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        );
    }
  }
}
