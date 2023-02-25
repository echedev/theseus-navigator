import 'package:flutter/material.dart';

import '../destination.dart';
import '../navigation_controller.dart';
import '../utils/log/log.dart';

/// Builds a navigation widget.
///
/// It is used by [NavigationController] to build a navigation widget sub-tree
/// around a content of destinations, managed by this navigation controller.
///
/// See also:
/// - [DefaultNavigatorBuilder]
/// - [BottomNavigationBuilder]
///
abstract class NavigatorBuilder {
  /// Creates an instance of [NavigatorBuilder].
  ///
  /// Does not keep upward destination by default.
  ///
  const NavigatorBuilder({
    this.keepUpwardDestination = KeepUpwardDestinationMode.none,
  });

  /// Automatic persisting of upward destination.
  ///
  final KeepUpwardDestinationMode keepUpwardDestination;

  /// Returns a widget that wraps a content of navigator's destinations.
  ///
  Widget build(BuildContext context, NavigationController navigator);
}

/// Implementation of [NavigatorBuilder] that manages a stack of destinations using
/// Flutter's [Navigator] widget.
///
class DefaultNavigatorBuilder extends NavigatorBuilder {
  /// Creates an instance of [DefaultNavigatorBuilder].
  ///
  /// Set [NavigatorBuilder.keepUpwardDestination] to [KeepUpwardDestinationMode.auto]
  /// by default to allow persisting navigation stack in the web browser history.
  ///
  const DefaultNavigatorBuilder({
    KeepUpwardDestinationMode? keepUpwardDestinationMode,
  }) : super(
            keepUpwardDestination:
                keepUpwardDestinationMode ?? KeepUpwardDestinationMode.auto);

  @override
  Widget build(BuildContext context, NavigationController navigator) {
    final pages = <_TheseusPage>[];
    for (int i = 0; i < navigator.stack.length; i++) {
      final destination = navigator.stack[i];
      pages.add(_TheseusPage(
        // TODO: Remove reference to 'i' in the key
        key: ValueKey('${destination.uri}-$i'),
        destination: destination,
      ));
    }
    return Navigator(
      key: navigator.key,
      pages: pages,
      onPopPage: (route, result) {
        Log.d(runtimeType, 'onPopPage()');
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
    switch (destination.settings.transition) {
      case DestinationTransition.material:
        return MaterialPageRoute(
          settings: this,
          builder: (context) => destination.build(context),
        );
      case DestinationTransition.materialDialog:
        return DialogRoute(
          context: context,
          settings: this,
          builder: (context) => destination.build(context),
        );
      case DestinationTransition.custom:
        return PageRouteBuilder(
          settings: this,
          pageBuilder: (context, animation, secondaryAnimation) =>
              destination.build(context),
          transitionsBuilder: destination.settings.transitionBuilder!,
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
