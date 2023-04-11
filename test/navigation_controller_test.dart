import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import 'common/index.dart';

void main() {
  late NavigationController navigator;

  late NavigationController navigatorCustomInitial;

  late NavigationController navigatorNotNotify;

  late NavigationController navigatorAlwaysKeepState;

  late NavigationController navigatorUpward;

  group('Navigation Controller', () {
    setUp(() {
      navigator = NavigationController(
        destinations: [
          TestDestinations.home,
          TestDestinations.catalog,
          TestDestinations.about,
        ],
      );
      navigatorCustomInitial = NavigationController(
        destinations: [
          TestDestinations.home,
          TestDestinations.catalog,
          TestDestinations.about,
        ],
        initialDestinationIndex: 2,
      );
      navigatorNotNotify = NavigationController(
        destinations: [
          TestDestinations.home,
          TestDestinations.catalog,
          TestDestinations.about,
        ],
        notifyOnError: false,
      );
    });
    group('Initial destination', () {
      test('Default initial destination is the first in the list', () {
        expect(navigator.currentDestination, TestDestinations.home);
      });
      test('Custom initial destination', () {
        expect(
            navigatorCustomInitial.currentDestination, TestDestinations.about);
      });
    });
    group('Navigation', () {
      test('Navigate to another destination by "push" method', () async {
        await navigator.goTo(TestDestinations.catalog);
        expect(navigator.currentDestination, TestDestinations.catalog);
        expect(navigator.stack.length, 2);
        expect(navigator.backFrom, null);
      });
      test('Navigate to another 2 destinations by "push" method', () async {
        await navigator.goTo(TestDestinations.catalog);
        await navigator.goTo(TestDestinations.about);
        expect(navigator.currentDestination, TestDestinations.about);
        expect(navigator.stack.length, 3);
        expect(navigator.backFrom, null);
      });
      test('Navigate to another destination by "push" method and return back',
          () async {
        await navigator.goTo(TestDestinations.catalog);
        navigator.goBack();
        expect(navigator.currentDestination, TestDestinations.home);
        expect(navigator.stack.length, 1);
        expect(navigator.backFrom, TestDestinations.catalog);
        expect(navigator.shouldClose, false);
      });
      test(
          'Navigate to another 2 destinations by "push" method and return back to initial destination',
          () async {
        await navigator.goTo(TestDestinations.catalog);
        await navigator.goTo(TestDestinations.about);
        navigator.goBack();
        navigator.goBack();
        expect(navigator.currentDestination, TestDestinations.home);
        expect(navigator.stack.length, 1);
        expect(navigator.backFrom, TestDestinations.catalog);
        expect(navigator.shouldClose, false);
      });
      test('Navigate to another destination by "replace" method', () async {
        await navigator.goTo(TestDestinations.catalog.withSettings(
            TestDestinations.catalog.settings
                .copyWith(transitionMethod: TransitionMethod.replace)));
        expect(navigator.currentDestination, TestDestinations.catalog);
        expect(navigator.stack.length, 1);
        expect(navigator.backFrom, null);
      });
      test('Navigate to the same destination will not change the stack',
          () async {
        await navigator.goTo(TestDestinations.home);
        expect(navigator.currentDestination, TestDestinations.home);
        expect(navigator.stack.length, 1);
        expect(navigator.backFrom, null);
      });
      test(
          'Navigate back from the last destination in the stack should set close flag',
          () {
        navigator.goBack();
        expect(navigator.currentDestination, TestDestinations.home);
        expect(navigator.stack.length, 1);
        expect(navigator.backFrom, TestDestinations.home);
        expect(navigator.shouldClose, true);
      });
    });
    group('Upward navigation', () {
      setUp(() {
        navigatorUpward = NavigationController(
          destinations: [
            TestDestinations.home,
            TestDestinations.categoriesTyped,
            TestDestinations.about,
          ],
        );
      });
      test('Missed destinations should be added to the stack', () async {
        final categories1 = TestDestinations.categoriesTyped.withParameters(
            CategoriesParameters(parent: categoriesDataSource[0]));
        final categories2 = TestDestinations.categoriesTyped.withParameters(
            CategoriesParameters(parent: categoriesDataSource[1]));
        final categories3 = TestDestinations.categoriesTyped.withParameters(
            CategoriesParameters(parent: categoriesDataSource[2]));
        await navigatorUpward.goTo(categories3);
        expect(navigatorUpward.currentDestination, categories3);
        expect(navigatorUpward.stack.length, 4);
        expect(navigatorUpward.stack[1], categories1);
        expect(navigatorUpward.stack[2], categories2);
        expect(navigatorUpward.backFrom, null);
        expect(navigatorUpward.shouldClose, false);
      });
      test('Upward destinations should not be duplicated, if some of them are already in the stack', () async {
        final categories1 = TestDestinations.categoriesTyped.withParameters(
            CategoriesParameters(parent: categoriesDataSource[0]));
        final categories2 = TestDestinations.categoriesTyped.withParameters(
            CategoriesParameters(parent: categoriesDataSource[1]));
        final categories3 = TestDestinations.categoriesTyped.withParameters(
            CategoriesParameters(parent: categoriesDataSource[2]));
        await navigatorUpward.goTo(categories1);
        expect(navigatorUpward.currentDestination, categories1);
        expect(navigatorUpward.stack.length, 2);
        await navigatorUpward.goTo(categories3);
        expect(navigatorUpward.currentDestination, categories3);
        expect(navigatorUpward.stack.length, 4);
        expect(navigatorUpward.stack[1], categories1);
        expect(navigatorUpward.stack[2], categories2);
        expect(navigatorUpward.backFrom, null);
        expect(navigatorUpward.shouldClose, false);
      });
    });
    group('Error handling', () {
      test('Navigation to nonexistent destination should set error', () async {
        await navigator.goTo(TestDestinations.login);
        expect(navigator.currentDestination, TestDestinations.home);
        expect(navigator.stack.length, 1);
        expect(navigator.error != null, true);
        expect(navigator.error.toString(),
            'NavigationControllerError: destination=/login');
      });
      test(
          'Throw exception when navigate to non-existent destination and the navigator is configured to not notify on errors ',
          () async {
        expect(
            () async => await navigatorNotNotify.goTo(TestDestinations.login),
            throwsA(isA<UnknownDestinationException>()));
        expect(navigatorNotNotify.currentDestination, TestDestinations.home);
        expect(navigatorNotNotify.stack.length, 1);
        // In case of exception the error is not set
        expect(navigatorNotNotify.error != null, false);
      });
    });
    group('Persisting of navigation state in destination parameters', () {
      setUp(() {
        navigator = NavigationController(
          destinations: [
            TestDestinations.home,
            TestDestinations.catalog,
            TestDestinations.about,
          ],
        );
        navigatorAlwaysKeepState = NavigationController(
          destinations: [
            TestDestinations.home,
            TestDestinations.catalog,
            TestDestinations.about,
          ],
          builder: const DefaultNavigatorBuilder(
              keepStateInParameters: KeepingStateInParameters.always),
        );
      });
      test('Do not keep navigation state in auto mode on non-web platform', () {
        expect(navigator.keepStateInParameters, false);
      });
      test('Explicitly keep navigation state', () {
        expect(navigatorAlwaysKeepState.keepStateInParameters, true);
      });
    });
  });
}
