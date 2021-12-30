import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../destination.dart';
import '../navigator.dart';

/// Builds a widget that wraps a content for [TheseusNavigator].
///
/// See also:
/// - [DefaultNavigatorBuilder]
///
abstract class NavigatorBuilder {
  /// Returns a widget that wraps a content of navigator's destinations.
  ///
  Widget build(BuildContext context, TheseusNavigator navigator);
}

/// Implementation of [NavigatorBuilder] that wraps destination's content into
/// [Navigator] widget.
///
class DefaultNavigatorBuilder implements NavigatorBuilder {
  /// Creates default navigator builder.
  ///
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
