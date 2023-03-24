import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import '../common/index.dart';

void main() {
  late NavigationScheme navigationScheme;

  late NavigationScheme navigationSchemeCustomWaiting;

  group('TheseusRouterDelegate Widgets', () {
    setUp(() {
      navigationScheme = NavigationScheme(
        destinations: [
          TestDestinations.home,
          TestDestinations.catalog,
          TestDestinations.aboutRedirectionNotApplied,
        ],
        errorDestination: TestDestinations.error,
      );
      navigationSchemeCustomWaiting = NavigationScheme(
        destinations: [
          TestDestinations.home,
          TestDestinations.catalog,
          TestDestinations.aboutRedirectionNotApplied,
        ],
        errorDestination: TestDestinations.error,
        waitingOverlayBuilder: (context, destination) => Container(
          key: const Key('_TheseusCustomWaitingOverlay_'),
          color: Colors.red,
        ),
      );
    });
    testWidgets('Delegate builds root Navigator', (tester) async {
      await tester.pumpWidget(_mainWrapper(navigationScheme: navigationScheme));
      await tester.pumpAndSettle();
      expect(find.byKey(navigationScheme.rootNavigator.key), findsOneWidget);
    });
    testWidgets('Show waiting overlay while resolving the destination',
        (tester) async {
      const waitingOverlayKey = Key('_TheseusWaitingOverlay_');
      await tester.pumpWidget(_mainWrapper(navigationScheme: navigationScheme));
      await tester.pumpAndSettle();
      expect(find.byKey(navigationScheme.rootNavigator.key), findsOneWidget);
      expect(find.byKey(waitingOverlayKey), findsNothing);
      navigationScheme.goTo(TestDestinations.aboutRedirectionNotApplied);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.byKey(waitingOverlayKey), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(waitingOverlayKey), findsNothing);
    });
    testWidgets('If provided, show custom waiting overlay while resolving the destination',
        (tester) async {
      const waitingOverlayKey = Key('_TheseusCustomWaitingOverlay_');
      await tester.pumpWidget(
          _mainWrapper(navigationScheme: navigationSchemeCustomWaiting));
      await tester.pumpAndSettle();
      expect(find.byKey(navigationSchemeCustomWaiting.rootNavigator.key),
          findsOneWidget);
      expect(find.byKey(waitingOverlayKey), findsNothing);
      navigationSchemeCustomWaiting.goTo(TestDestinations.aboutRedirectionNotApplied);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.byKey(waitingOverlayKey), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byKey(waitingOverlayKey), findsNothing);
    });
  });
}

Widget _mainWrapper({
  required NavigationScheme navigationScheme,
}) {
  return MaterialApp.router(
    routerDelegate: navigationScheme.routerDelegate,
    routeInformationParser: navigationScheme.routeParser,
  );
}
