import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import 'common/common.dart';

void main() {
  late NavigationController navigator;

  late NavigationController navigatorCustomInitial;

  late NavigationController navigatorNotNotify;

  late NavigationController navigatorAlwaysKeepUpward;

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
      test('Navigate to another destination with "push" action', () async {
        await navigator.goTo(TestDestinations.catalog);
        expect(navigator.currentDestination, TestDestinations.catalog);
        expect(navigator.stack.length, 2);
        expect(navigator.backFrom, null);
      });
      test('Navigate to another 2 destinations with "push" action', () async {
        await navigator.goTo(TestDestinations.catalog);
        await navigator.goTo(TestDestinations.about);
        expect(navigator.currentDestination, TestDestinations.about);
        expect(navigator.stack.length, 3);
        expect(navigator.backFrom, null);
      });
      test('Navigate to another destination with "push" action and return back',
          () async {
        await navigator.goTo(TestDestinations.catalog);
        navigator.goBack();
        expect(navigator.currentDestination, TestDestinations.home);
        expect(navigator.stack.length, 1);
        expect(navigator.backFrom, TestDestinations.catalog);
        expect(navigator.shouldClose, false);
      });
      test(
          'Navigate to another 2 destinations with "push" action and return back to initial destination',
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
    group('Error handling', () {
      test('Navigation to nonexistent destination should set error', () async {
        await navigator.goTo(TestDestinations.login);
        expect(navigator.currentDestination, TestDestinations.home);
        expect(navigator.stack.length, 1);
        expect(navigator.error != null, true);
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
    group('Persisting upward destination', ()
    {
      setUp(() {
        navigator = NavigationController(
          destinations: [
            TestDestinations.home,
            TestDestinations.catalog,
            TestDestinations.about,
          ],
        );
        navigatorAlwaysKeepUpward = NavigationController(
          destinations: [
            TestDestinations.home,
            TestDestinations.catalog,
            TestDestinations.about,
          ],
          builder: const DefaultNavigatorBuilder(keepUpwardDestinationMode: KeepUpwardDestinationMode.always),
        );
      });
      test('Do not keep upward destination in auto mode by default', () {
        expect(navigator.keepUpwardDestination, false);
      });
      test('Explicitly keep upward destination', () {
        expect(navigatorAlwaysKeepUpward.keepUpwardDestination, true);
      });
    });
  });
}
