import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import 'common/index.dart';

void main() {
  late NavigationScheme navigationScheme;

  late NavigationScheme navigationSchemeNoError;

  late TheseusRouterDelegate delegate;

  group('TheseusRouterDelegate', () {
    setUp(() {
      navigationScheme = NavigationScheme(
        destinations: [
          TestDestinations.home,
          TestDestinations.catalog,
          TestDestinations.about,
        ],
        errorDestination: TestDestinations.error,
      );
      navigationSchemeNoError = NavigationScheme(
        destinations: [
          TestDestinations.home,
          TestDestinations.catalog,
          TestDestinations.about,
        ],
      );
      delegate = TheseusRouterDelegate(
        navigationScheme: navigationScheme,
      );
    });
    group('Set new route', () {
      test('New route is pushed to the app by OS', () async {
        await delegate.setNewRoutePath(TestDestinations.about);
        expect(delegate.currentConfiguration, TestDestinations.about);
        expect(navigationScheme.currentDestination, TestDestinations.about);
        expect(navigationScheme.findNavigator(navigationScheme.currentDestination)?.stack.length, 2);
      });
      test('New route with "upwardDestinationBuilder" is pushed to the app by OS', () async {
        final destination = TestDestinations.categoriesTyped
            .withParameters(CategoriesParameters(parent: categoriesDataSource[0]));
        await delegate.setNewRoutePath(destination);
        expect(navigationScheme.currentDestination, destination);
        expect(navigationScheme.findNavigator(navigationScheme.currentDestination)?.stack.length, 2);
      });
    });
    group('Pop route', () {
      test('Popping the only route should keep the current destination on non-Android platform', () async {
        final result = await delegate.popRoute();
        expect(result, true);
        expect(navigationScheme.currentDestination, TestDestinations.home);
      });
      test('Popping the current route should set the current destination to previous one', () async {
        await navigationScheme.goTo(TestDestinations.about);
        expect(navigationScheme.currentDestination, TestDestinations.about);
        expect(navigationScheme.findNavigator(navigationScheme.currentDestination)?.stack.length, 2);
        final result = await delegate.popRoute();
        expect(result, true);
        expect(navigationScheme.currentDestination, TestDestinations.home);
      });
    });
    group('Service', () {
      test('Stop listen to navigation scheme on dispose', () async {
        expect(navigationScheme.hasListeners, true);
        delegate.dispose();
        expect(navigationScheme.hasListeners, false);
      });
    });
  });
}
