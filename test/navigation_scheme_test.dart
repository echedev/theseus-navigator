// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import 'common/common.dart';

void main() {
  late NavigationScheme navigationScheme;

  late NavigationScheme navigationSchemeNoError;

  TestWidgetsFlutterBinding.ensureInitialized();

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
            navigationScheme.findDestination(Uri.parse('/home')), TestDestinations.home);
        expect(navigationScheme.findDestination(Uri.parse('/catalog')),
            TestDestinations.catalog);
        expect(navigationScheme.findDestination(Uri.parse('/categories')),
            TestDestinations.categories);
        expect(navigationScheme.findDestination(Uri.parse('/categories/1')),
            TestDestinations.categories);
      });
      test('Finding home destination', () {
        expect(navigationScheme.findDestination(Uri.parse('/')), TestDestinations.home);
      });
      test('Finding nonexistent destination', () {
        expect(navigationScheme.findDestination(Uri.parse('/login')), null);
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
      test(
          'Initial destination is a one, which has "isHome" parameter set to "true" independent on its position in the destination list',
          () {
        expect(navigationScheme.currentDestination, TestDestinations.home);

        final navigationScheme1 = NavigationScheme(
          destinations: [
            TestDestinations.catalog,
            TestDestinations.home,
            TestDestinations.about,
          ],
        );
        expect(navigationScheme1.currentDestination, TestDestinations.home);
      });
      test('Navigate to another primary destination', () async {
        await navigationScheme.goTo(TestDestinations.about);
        expect(navigationScheme.currentDestination, TestDestinations.about);
      });
      test(
          'Navigate to transit destination makes the current destination set to first nested destination',
          () async {
        await navigationScheme.goTo(TestDestinations.catalog);
        expect(
            navigationScheme.currentDestination, TestDestinations.categories);
      });
      test('Navigate to nested destination', () async {
        await navigationScheme.goTo(TestDestinations.categories);
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
            TestDestinations.aboutRedirectionApplied,
            TestDestinations.login,
          ],
        );
      });
      test('Home destination can be redirected', () async {
        final navigationScheme = NavigationScheme(
          destinations: [
            TestDestinations.homeRedirectionApplied,
            TestDestinations.login,
          ],
        );
        await Future.delayed(const Duration(seconds: 1));
        expect(navigationScheme.currentDestination, TestDestinations.login);
      });
      test(
          'Original destination is saved in the settings of redirection destination',
          () async {
        await navigationScheme.goTo(TestDestinations.aboutRedirectionApplied);
        expect(navigationScheme.currentDestination, TestDestinations.login);
        expect(navigationScheme.currentDestination.settings.redirectedFrom,
            TestDestinations.aboutRedirectionApplied);
        expect(navigationScheme.redirectedFrom,
            TestDestinations.aboutRedirectionApplied);
      });
      test(
          'User can navigate back from the redirected destination reached with "push" method, even the validation is still failed',
          () async {
        await navigationScheme.goTo(TestDestinations.aboutRedirectionApplied);
        expect(navigationScheme.currentDestination, TestDestinations.login);
        await navigationScheme.goBack();
        expect(navigationScheme.currentDestination,
            TestDestinations.aboutRedirectionApplied);
      });
      test(
          'User can navigate back from the redirected destination reached with "replace" method, in case the validation is passed',
          () async {
        bool isValid = false;
        final destinationWithRedirection = Destination(
          path: '/settings/about',
          builder: TestDestinations.dummyBuilder,
          redirections: [
            Redirection(
              destination: TestDestinations.login.copyWith(
                  settings: const DestinationSettings.material()
                      .copyWith(transitionMethod: TransitionMethod.replace)),
              validator: (destination) async => isValid,
            ),
          ],
        );
        final navigationScheme = NavigationScheme(
          destinations: [
            TestDestinations.home,
            destinationWithRedirection,
            TestDestinations.login,
          ],
        );
        await Future.delayed(const Duration(seconds: 1));

        await navigationScheme.goTo(destinationWithRedirection);
        expect(navigationScheme.currentDestination, TestDestinations.login);
        isValid = true;
        await navigationScheme.goBack();
        expect(navigationScheme.currentDestination, destinationWithRedirection);
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
            navigationScheme.findDestination(Uri.parse('/error')), TestDestinations.error);
      });
      test(
          'For custom root navigator, if the error destination is provided, it should be included to the navigation scheme',
          () {
        expect(navigationSchemeCustom.findDestination(Uri.parse('/error')),
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
    group('Persisting of navigation state in destination parameters', () {
      late NavigationScheme navigationSchemeKeepState;

      setUp(() {
        navigationSchemeKeepState = NavigationScheme(
          navigator: NavigationController(
            destinations: [
              TestDestinations.home,
              TestDestinations.login,
              TestDestinations.about,
            ],
            builder: const DefaultNavigatorBuilder(
                keepStateInParameters: KeepingStateInParameters.always),
          ),
        );
      });
      test('Navigation state is not persisted by default on non-web platform',
          () async {
        await navigationScheme.goTo(TestDestinations.about);
        expect(navigationScheme.currentDestination, TestDestinations.about);
        expect(
            navigationScheme.currentDestination.parameters?.map
                    .containsKey([DestinationParameters.stateParameterName]) ??
                false,
            false);
      });
      test(
          'When enabled, the navigation state should persist in the parameters of requested destination.',
          () async {
        final upwardDestination = navigationSchemeKeepState.currentDestination;
        await navigationSchemeKeepState.goTo(TestDestinations.about);
        expect(
            TestDestinations.about
                .isMatch(navigationSchemeKeepState.currentDestination.uri),
            true);
        expect(
            navigationSchemeKeepState.currentDestination.parameters?.map
                    .containsKey(DestinationParameters.stateParameterName) ??
                false,
            true);
        final encodedState = navigationSchemeKeepState.currentDestination
                .parameters?.map[DestinationParameters.stateParameterName] ??
            '';
        final persistedState =
            jsonDecode(String.fromCharCodes(base64.decode(encodedState)));
        expect(persistedState['/'].contains(upwardDestination.path), true);
      });
      test(
          'Navigation stack should be restored on navigation to a destination containing navigation state in parameters.',
          () async {
        await navigationSchemeKeepState.goTo(TestDestinations.about);
        final destinationWithState =
            navigationSchemeKeepState.currentDestination;
        await navigationSchemeKeepState.goTo(TestDestinations.login
            .withSettings(
                TestDestinations.login.settings.copyWith(reset: true)));
        expect(navigationSchemeKeepState.currentDestination.path,
            TestDestinations.login.path);
        expect(navigationSchemeKeepState.rootNavigator.stack.length, 1);
        await navigationSchemeKeepState.goTo(destinationWithState
            .withSettings(destinationWithState.settings.copyWith(reset: true)));
        expect(
            navigationSchemeKeepState.currentDestination, destinationWithState);
        expect(navigationSchemeKeepState.rootNavigator.stack.length, 2);
        expect(navigationSchemeKeepState.rootNavigator.stack[0],
            TestDestinations.home);
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
