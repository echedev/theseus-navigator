import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import 'common.dart';

void main() {
  late TheseusNavigator navigator;
  group('Theseus Navigator', () {
    setUp(() {
      navigator = TheseusNavigator(
        destinations: [
          TestDestinations.home,
          TestDestinations.catalog,
          TestDestinations.about,
        ],
      );
    });
    group('Initial destination', () {
      test('Default initial destination is the first in the list', () {
        expect(navigator.currentDestination, TestDestinations.home);
      });
      test('Custom initial destination', () {
        navigator = TheseusNavigator(
          destinations: [
            TestDestinations.home,
            TestDestinations.catalog,
            TestDestinations.about,
          ],
          initialDestinationIndex: 2
        );
        expect(navigator.currentDestination, TestDestinations.about);
      });
    });
    group('Navigation', () {
      test('Navigate to another destination with "push" action', () async {
        await navigator.goTo(TestDestinations.catalog);
        expect(navigator.currentDestination, TestDestinations.catalog);
        expect(navigator.stack.length, 2);
      });
      test('Navigate to another 2 destinations with "push" action', () async {
        await navigator.goTo(TestDestinations.catalog);
        await navigator.goTo(TestDestinations.about);
        expect(navigator.currentDestination, TestDestinations.about);
        expect(navigator.stack.length, 3);
      });
      test('Navigate to another destination with "push" action and return back', () async {
        await navigator.goTo(TestDestinations.catalog);
        navigator.goBack();
        expect(navigator.currentDestination, TestDestinations.home);
        expect(navigator.stack.length, 1);
        expect(navigator.shouldClose, false);
      });
      test('Navigate to another 2 destinations with "push" action and return back to initial destination', () async {
        await navigator.goTo(TestDestinations.catalog);
        await navigator.goTo(TestDestinations.about);
        navigator.goBack();
        navigator.goBack();
        expect(navigator.currentDestination, TestDestinations.home);
        expect(navigator.stack.length, 1);
        expect(navigator.shouldClose, false);
      });
      test('Navigate to the same destination will not change the stack', () async {
        await navigator.goTo(TestDestinations.home);
        expect(navigator.currentDestination, TestDestinations.home);
        expect(navigator.stack.length, 1);
      });
      test('Navigate back from the last destination in the stack should set close flag', () {
        navigator.goBack();
        expect(navigator.currentDestination, TestDestinations.home);
        expect(navigator.stack.length, 1);
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
    });
  });
}
