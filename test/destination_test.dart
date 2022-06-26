import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import 'common.dart';

void main() {
  group('Destination', () {
    test('Equality', () {
      final categoryParametersId1 =
          DefaultDestinationParameters(<String, String>{'id': '1'});
      final categoryParametersId2 =
          DefaultDestinationParameters(<String, String>{'id': '2'});
      final categoryParametersId1Q1 =
          DefaultDestinationParameters(<String, String>{'id': '1', 'q': '1'});
      expect(TestDestinations.home == TestDestinations.home, true);
      expect(TestDestinations.home == TestDestinations.about, false);
      expect(TestDestinations.categories == TestDestinations.categories, true);
      expect(
          TestDestinations.categories
                  .withParameters(categoryParametersId1) ==
              TestDestinations.categories
                  .withParameters(categoryParametersId1),
          true);
      expect(
          TestDestinations.categories
                  .withParameters(categoryParametersId1) ==
              TestDestinations.categories
                  .withParameters(categoryParametersId2),
          false);
      expect(
          TestDestinations.categories
                  .withParameters(categoryParametersId1) ==
              TestDestinations.categories
                  .withParameters(categoryParametersId1Q1),
          false);
      expect(TestDestinations.home != TestDestinations.about, true);
    });
    test('Matching URI', () {
      final destination1 = TestDestinations.categories;
      final destination2 = destination1.withParameters(
          DefaultDestinationParameters(<String, String>{'id': '1'}));
      expect(destination1.isMatch('/categories/1'), true);
      expect(destination1.isMatch('/categories'), true);
      expect(destination1.isMatch('/home'), false);
      expect(destination2.isMatch('/categories/1'), true);
    });
    test('Parsing URI', () async {
      final destination1 = TestDestinations.categories;
      final destination2 = destination1.withParameters(
          DefaultDestinationParameters(<String, String>{'id': '1'}));
      final destination3 = destination1.withParameters(
          DefaultDestinationParameters(<String, String>{'id': '2'}));
      expect(await destination1.parse('/categories/1') == destination2, true);
      expect(await destination1.parse('/categories/1') == destination3, false);
    });
  });
}
