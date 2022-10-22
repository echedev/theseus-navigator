// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import 'common/common.dart';

void main() {
  late NavigationScheme navigationScheme;

  late NavigationScheme navigationSchemeNoError;

  group('Navigation Scheme', () {
    setUp(() {
      navigationScheme = NavigationScheme(
        destinations: [
          TestDestinations.home,
          TestDestinations.catalog,
          TestDestinations.about,
        ],
      );
    });
    group('Finding destinations and navigators', () {
      test('Finding existing destination', () {
        expect(
            navigationScheme.findDestination('/home'), TestDestinations.home);
        expect(navigationScheme.findDestination('/catalog'),
            TestDestinations.catalog);
        expect(navigationScheme.findDestination('/categories'),
            TestDestinations.categories);
        expect(navigationScheme.findDestination('/categories/1'),
            TestDestinations.categories);
      });
      test('Finding home destination', () {
        expect(navigationScheme.findDestination('/'), TestDestinations.home);
      });
      test('Finding nonexistent destination', () {
        expect(navigationScheme.findDestination('/login'), null);
      });
      test('Finding navigator for existing destination', () {
        expect(navigationScheme.findNavigator(TestDestinations.home),
            navigationScheme.rootNavigator);
        expect(navigationScheme.findNavigator(TestDestinations.catalog),
            navigationScheme.rootNavigator);
        expect(navigationScheme.findNavigator(TestDestinations.categories),
            TestNavigators.catalog);
        expect(
            navigationScheme.findNavigator(TestDestinations.categories
                .withParameters(
                    DestinationParameters(<String, String>{'id': '1'}))),
            TestNavigators.catalog);
      });
      test('Finding navigator for nonexistent destination', () {
        expect(navigationScheme.findNavigator(TestDestinations.login), null);
      });
    });
    group('General navigation', () {
      test('Initial destination is a first one in the list', () {
        expect(navigationScheme.currentDestination, TestDestinations.home);
      });
      test('Navigate to another primary destination', () async {
        await navigationScheme.goTo(TestDestinations.about);
        expect(navigationScheme.currentDestination, TestDestinations.about);
      });
      test('Navigate to nested destination', () async {
        await navigationScheme.goTo(TestDestinations.catalog);
        expect(
            navigationScheme.currentDestination, TestDestinations.categories);
      });
      test('Navigate to another primary destination and return back', () async {
        await navigationScheme.goTo(TestDestinations.about);
        navigationScheme.goBack();
        expect(navigationScheme.currentDestination, TestDestinations.home);
        expect(navigationScheme.shouldClose, false);
      });
      test(
          'Navigate back when the only destination is in the stack should close the app',
          () {
        navigationScheme.goBack();
        expect(navigationScheme.shouldClose, true);
      });
    });
    group('Redirection', () {
      setUp(() {
        navigationScheme = NavigationScheme(
          destinations: [
            TestDestinations.home,
            TestDestinations.catalog,
            TestDestinations.about,
            TestDestinations.login,
          ],
        );
      });
      test('Current destination is stored after redirection', () async {
        await navigationScheme.goTo(TestDestinations.login,
            isRedirection: true);
        expect(navigationScheme.currentDestination, TestDestinations.login);
        expect(navigationScheme.redirectedFrom, TestDestinations.home);
      });
      test('User can navigate back from the redirected destination', () async {
        await navigationScheme.goTo(TestDestinations.login,
            isRedirection: true);
        navigationScheme.goBack();
        expect(navigationScheme.currentDestination, TestDestinations.home);
      });
    });
    group('Error handling', () {
      late NavigationScheme navigationSchemeCustom;

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
        navigationSchemeCustom = NavigationScheme(
          navigator: NavigationController(
            destinations: [
              TestDestinations.home,
              TestDestinations.catalog,
              TestDestinations.about,
              TestDestinations.error,
            ],
          ),
          errorDestination: TestDestinations.error,
        );
      });
      test(
          'When provided, the error destination is included to the navigation scheme',
          () {
        expect(
            navigationScheme.findDestination('/error'), TestDestinations.error);
      });
      test(
          'For custom root navigator, if the error destination is provided, it should be included to the navigation scheme',
          () {
        expect(navigationSchemeCustom.findDestination('/error'),
            TestDestinations.error);
      });
      test(
          'Redirect to error destination when navigate to non-existent destination',
          () async {
        await navigationScheme.goTo(TestDestinations.login);
        expect(navigationScheme.currentDestination, TestDestinations.error);
      });
      test('User can navigate back from the error destination', () async {
        await navigationScheme.goTo(TestDestinations.login);
        navigationScheme.goBack();
        expect(navigationScheme.currentDestination, TestDestinations.home);
      });
      test('Throw an exception if no error destination provided', () async {
        expect(
            () async =>
                await navigationSchemeNoError.goTo(TestDestinations.login),
            throwsA(isA<UnknownDestinationException>()));
      });
    });
    group('Service', () {
      test('Stop listen to navigators on dispose', () async {
        expect(navigationScheme.rootNavigator.hasListeners, true);
        navigationScheme.dispose();
        expect(navigationScheme.rootNavigator.hasListeners, false);
      });
    });
  });
}
