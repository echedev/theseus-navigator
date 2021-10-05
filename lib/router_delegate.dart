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
    return navigationScheme.rootNavigator.build(context);
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

// TODO: Add description
abstract class NavigatorBuilder {
  Widget build(BuildContext context, TheseusNavigator navigator);
}

// TODO: Add description
class DefaultNavigatorBuilder implements NavigatorBuilder {
  const DefaultNavigatorBuilder();

  @override
  Widget build(BuildContext context, TheseusNavigator navigator) {
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
      case DestinationTransition.custom:
        return PageRouteBuilder(
          settings: this,
          pageBuilder: (context, animation, secondaryAnimation) =>
              destination.build(context),
          transitionsBuilder: destination.configuration.transitionBuilder!,
        );
      case DestinationTransition.none:
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
