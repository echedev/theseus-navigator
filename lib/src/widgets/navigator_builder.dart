import 'package:flutter/material.dart';

import '../destination.dart';
import '../navigation_controller.dart';

/// Builds a widget that wraps a content for [NavigationController].
///
/// See also:
/// - [DefaultNavigatorBuilder]
/// - [BottomNavigationBuilder]
///
abstract class NavigatorBuilder {
  /// Returns a widget that wraps a content of navigator's destinations.
  ///
  Widget build(BuildContext context, NavigationController navigator);
}

/// Implementation of [NavigatorBuilder] that wraps destination's content into
/// [Navigator] widget.
///
class DefaultNavigatorBuilder implements NavigatorBuilder {
  /// Creates default navigator builder.
  ///
  const DefaultNavigatorBuilder();

  @override
  Widget build(BuildContext context, NavigationController navigator) {
    final pages = <_TheseusPage>[];
    for (int i = 0; i < navigator.stack.length; i++) {
      final destination = navigator.stack[i];
      pages.add(_TheseusPage(
        key: ValueKey('${destination.uri}-$i'),
        destination: destination,
      ));
    }
    return Navigator(
      key: navigator.key,
      pages: pages,
      onPopPage: (route, result) {
        navigator.goBack();
        route.didPop(result);
        return true;
      },
    );
  }
}

class _TheseusPage extends Page {
  const _TheseusPage({
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
