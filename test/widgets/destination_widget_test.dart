import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import '../common/index.dart';

void main() {
  group('Destination Widgets', () {
    setUp(() {});
    testWidgets('Transit destination builds wrapper widget', (tester) async {
      await tester.pumpWidget(
          _destinationWrapper(destination: TestDestinations.catalogTransit));
      await tester.pumpAndSettle();
      expect(find.text('Catalog'), findsOneWidget);
    });

    testWidgets('Copy of transit destination builds wrapper widget',
        (tester) async {
      await tester.pumpWidget(_destinationWrapper(
          destination: TestDestinations.catalogTransit.withSettings(
              TestDestinations.catalogTransit.settings
                  .copyWith(transitionMethod: TransitionMethod.replace))));
      await tester.pumpAndSettle();
      expect(find.text('Catalog'), findsOneWidget);
    });
  });
}

Widget _destinationWrapper({
  required Destination destination,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) => destination.build(context),
    ),
  );
}
