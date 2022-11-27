import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'destination.dart';
import 'navigation_controller.dart';
import 'navigation_scheme.dart';
import 'utils/utils.dart';

/// Implementation of [RouterDelegate].
///
/// Uses [navigationScheme] to build routes.
///
/// See also:
/// - [NavigationScheme]
/// - [NavigationController]
/// - [Destination]
///
class TheseusRouterDelegate extends RouterDelegate<Destination>
    with ChangeNotifier {
  /// Creates router delegate.
  ///
  TheseusRouterDelegate({
    required this.navigationScheme,
  }) {
    Log.d(runtimeType, 'TheseusRouterDelegate():');
    _key = GlobalKey<NavigatorState>(debugLabel: 'TheseusNavigator');
    navigationScheme.addListener(_onCurrentDestinationChanged);
  }

  /// A navigation scheme that contains destinations and navigators.
  ///
  /// This router delegate is listening the navigation scheme to identify if the
  /// current destination is changed, and in turn, notifies its listeners when this
  /// happens.
  ///
  final NavigationScheme navigationScheme;

  late final GlobalKey<NavigatorState> _key;

  @override
  Widget build(BuildContext context) {
    Log.d(runtimeType, 'build(): isResolving=${navigationScheme.isResolving}');
    return Navigator(
      key: _key,
      pages: [
        MaterialPage(
          key: const ValueKey('TheseusRootPage'),
          child: navigationScheme.rootNavigator.build(context),
        ),
        if (navigationScheme.isResolving)
          _TheseusPageOverlay(
            child: navigationScheme.waitingOverlayBuilder?.call(context, navigationScheme.currentDestination)
                ?? const _TheseusWaitingOverlay(
                  key: Key('_TheseusWaitingOverlay_'),
                ),
          ),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
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
    Log.d(runtimeType, 'setNewRoutePath(): destination=$destination');
    // The current navigation stack is reset if the new destination is not an error.
    final reset = destination != navigationScheme.errorDestination;
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
    Log.d(
        runtimeType, 'onCurrentDestinationChanged(): destination=$destination');
    // Ignore closing app request here. It is processed in the 'popRoute()' method.
    if (navigationScheme.shouldClose) {
      return;
    }
    notifyListeners();
  }
}

class _TheseusPageOverlay extends Page {
  const _TheseusPageOverlay({
    required this.child,
    LocalKey? key,
  }) : super(key: key);

  final Widget child;

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
  }
}

class _TheseusWaitingOverlay extends StatelessWidget {
  const _TheseusWaitingOverlay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          color: Colors.black.withAlpha(128),
          dismissible: false,
        ),
        const Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}
