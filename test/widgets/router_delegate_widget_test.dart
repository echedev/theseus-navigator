import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import '../common/index.dart';

void main() {
  late NavigationScheme navigationScheme;

  group('TheseusRouterDelegate Widgets', () {
    setUp(() {
      navigationScheme = NavigationScheme(
        destinations: [
          TestDestinations.home,
          TestDestinations.catalog,
          TestDestinations.aboutWithRedirection,
        ],
        errorDestination: TestDestinations.error,
      );
    });
    testWidgets('Delegate builds root Navigator', (tester) async {
      await tester.pumpWidget(_mainWrapper(navigationScheme: navigationScheme));
      await tester.pumpAndSettle();
      expect(find.byKey(navigationScheme.rootNavigator.key), findsOneWidget);
    });
    testWidgets('Show waiting overlay when resolving the destination',
        (tester) async {
      const waitingOverlayKey = Key('_TheseusWaitingOverlay_');
      await tester.pumpWidget(_mainWrapper(navigationScheme: navigationScheme));
      await tester.pumpAndSettle();
      expect(find.byKey(navigationScheme.rootNavigator.key), findsOneWidget);
      expect(find.byKey(waitingOverlayKey), findsNothing);
      navigationScheme.goTo(TestDestinations.aboutWithRedirection);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.byKey(waitingOverlayKey), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(waitingOverlayKey), findsNothing);
    });
  });
}

Widget _mainWrapper({
  required NavigationScheme navigationScheme,
}) {
  return MaterialApp.router(
    routerDelegate: TheseusRouterDelegate(
      navigationScheme: navigationScheme,
    ),
    routeInformationParser: TheseusRouteInformationParser(
      navigationScheme: navigationScheme,
    ),
  );
}
