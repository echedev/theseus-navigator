// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';
import 'package:theseus_navigator/src/router_delegate.dart';

import 'common/index.dart';

void main() {
  late NavigationScheme navigationScheme;

  late TheseusRouterDelegate delegate;

  late List<String> log;

  void currentDestinationListener() {
    log.add(navigationScheme.currentDestination.uri);
  }

  group('TheseusRouterDelegate', () {
    setUp(() {
      navigationScheme = NavigationScheme(
        destinations: [
          TestDestinations.home,
          TestDestinations.about,
          TestDestinations.categoriesTyped,
        ],
        errorDestination: TestDestinations.error,
      );

      delegate = navigationScheme.routerDelegate;

      log = <String>[];

      navigationScheme.addListener(currentDestinationListener);
    });
    group('Set new route by the platform', () {
      test('New route is pushed to the app', () async {
        await delegate.setNewRoutePath(TestDestinations.about);
        expect(delegate.currentConfiguration, TestDestinations.about);
        expect(navigationScheme.currentDestination, TestDestinations.about);
        expect(
            navigationScheme
                .findNavigator(navigationScheme.currentDestination)
                ?.stack
                .length,
            1);
      });
      test(
          'New route with custom "upwardDestinationBuilder" is pushed to the app',
          () async {
        final destination = TestDestinations.categoriesTyped.withParameters(
            CategoriesParameters(parent: categoriesDataSource[1]));
        await delegate.setNewRoutePath(destination);
        expect(navigationScheme.currentDestination, destination);
        expect(
            navigationScheme
                .findNavigator(navigationScheme.currentDestination)
                ?.stack
                .length,
            2);
      });
      test(
          'Pushing the same route as the current one should not cause notifying router delegate by navigation scheme',
              () async {
            final destination = TestDestinations.home;
            await delegate.setNewRoutePath(destination);

            expect(log.length, 0);
            expect(navigationScheme.currentDestination, destination);
            expect(
                navigationScheme
                    .findNavigator(navigationScheme.currentDestination)
                    ?.stack
                    .length,
                1);
          });
    });
    group('Pop route', () {
      test(
          'Popping the only route should keep the current destination on non-Android platform',
          () async {
        final result = await delegate.popRoute();
        expect(result, true);
        expect(navigationScheme.currentDestination, TestDestinations.home);
      });
      test(
          'Popping the current route should set the current destination to previous one',
          () async {
        await navigationScheme.goTo(TestDestinations.about);
        expect(navigationScheme.currentDestination, TestDestinations.about);
        expect(
            navigationScheme
                .findNavigator(navigationScheme.currentDestination)
                ?.stack
                .length,
            2);
        final result = await delegate.popRoute();
        expect(result, true);
        expect(navigationScheme.currentDestination, TestDestinations.home);
      });
    });
    group('Service', () {
      test('Stop listen to navigation scheme on dispose', () async {
        expect(navigationScheme.hasListeners, true);
        navigationScheme.removeListener(currentDestinationListener);
        navigationScheme.routerDelegate.dispose();
        expect(navigationScheme.hasListeners, false);
      });
    });
  });
}
