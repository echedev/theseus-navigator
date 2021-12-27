import 'dart:io';

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
      }
      else {
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
    // Don't reset stack if redirected to the 'errorDestination', to be able return
    // back to previous destination.
    final reset = (destination != navigationScheme.errorDestination);
    return SynchronousFuture(navigationScheme.goTo(
        destination.copyWithConfiguration(
            destination.configuration.copyWith(reset: reset))));
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
    // This is a 'happy path', just notifying Router to update the UI
    if (destination.redirections.isEmpty) {
      notifyListeners();
      return;
    }
    // Ignore redirections if we returned back from the redirection
    if (navigationScheme.redirectedFrom == destination) {
      notifyListeners();
      return;
    }
    // Apply redirections if they are specified.
    for (var redirection in destination.redirections) {
      if (!(await redirection.validate(destination))) {
        return SynchronousFuture(navigationScheme.goTo(redirection.destination,
            isRedirection: true));
      }
    }
    // No one redirection was applied.
    notifyListeners();
  }
}

/// Builds a widget that wraps a content for [TheseusNavigator].
///
/// See also:
/// - [DefaultNavigatorBuilder]
///
abstract class NavigatorBuilder {
  /// Returns a widget that wraps content of navigator's destinations.
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