import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_test/flutter_test.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

import 'common/index.dart';

void main() {
  group('Destination', () {
    test('Equality', () {
      final categoryParametersId1 =
          DestinationParameters(<String, String>{'id': '1'});
      final categoryParametersId2 =
          DestinationParameters(<String, String>{'id': '2'});
      final categoryParametersId1Q1 =
          DestinationParameters(<String, String>{'id': '1', 'q': '1'});
      expect(TestDestinations.home == TestDestinations.home, true);
      expect(TestDestinations.home == TestDestinations.about, false);
      expect(TestDestinations.categories == TestDestinations.categories, true);
      expect(
          TestDestinations.categories.withParameters(categoryParametersId1) ==
              TestDestinations.categories.withParameters(categoryParametersId1),
          true);
      expect(
          TestDestinations.categories.withParameters(categoryParametersId1) ==
              TestDestinations.categories.withParameters(categoryParametersId2),
          false);
      expect(
          TestDestinations.categories.withParameters(categoryParametersId1) ==
              TestDestinations.categories
                  .withParameters(categoryParametersId1Q1),
          false);
      expect(TestDestinations.home != TestDestinations.about, true);
    });
    test('Matching URI', () {
      final destination1 = TestDestinations.categories;
      final destination2 = destination1
          .withParameters(DestinationParameters(<String, String>{'id': '1'}));
      expect(destination1.isMatch('/categories/1'), true);
      expect(destination1.isMatch('/categories'), true);
      expect(destination1.isMatch('/home'), false);
      expect(destination2.isMatch('/categories/1'), true);
    });
    test('Parsing URI', () async {
      final destination1 = TestDestinations.categories;
      final destination2 = destination1
          .withParameters(DestinationParameters(<String, String>{'id': '1'}));
      final destination3 = destination1
          .withParameters(DestinationParameters(<String, String>{'id': '2'}));
      expect(await destination1.parse('/categories/1') == destination2, true);
      expect(await destination1.parse('/categories/1') == destination3, false);
    });
    test('Parsing URI - typed parameters', () async {
      final destination1 = TestDestinations.categoriesTyped;
      const parentCategory1 = Category(id: 1, name: 'Category 1');
      const parentCategory2 = Category(id: 2, name: 'Category 2');
      final destination2 = destination1
          .withParameters(CategoriesParameters(parent: parentCategory1));
      final destination3 = destination1
          .withParameters(CategoriesParameters(parent: parentCategory2));
      final result = await destination1.parse('/categories/1');
      expect(result == destination2, true);
      expect(result.parameters is CategoriesParameters, true);
      expect(result.parameters!.parent == parentCategory1, true);
      expect(result == destination3, false);
    });
    test('Applying parameters', () async {
      final destination1 = TestDestinations.categories;
      final categoryParametersId1 =
          DestinationParameters(<String, String>{'id': '1'});
      final destination2 = destination1.withParameters(categoryParametersId1);
      expect(destination2.parameters is CategoriesParameters, false);
      expect(destination2.parameters!.map.isNotEmpty, true);
      expect(
          mapEquals(destination2.parameters!.map, <String, String>{'id': '1'}),
          true);
    });
    test('Applying parameters - Typed parameters', () async {
      final destination1 = TestDestinations.categoriesTyped;
      const parentCategory1 = Category(id: 1, name: 'Category 1');
      final destination2 = destination1
          .withParameters(CategoriesParameters(parent: parentCategory1));
      expect(destination2.parameters is CategoriesParameters, true);
      expect(destination2.parameters!.map.isNotEmpty, true);
      expect(
          mapEquals(
              destination2.parameters!.map, <String, String>{'parentId': '1'}),
          true);
    });
    test('Settings to display a dialog', () async {
      final destination1 = TestDestinations.aboutWithDialogSettings;
      expect(destination1.settings.transitionMethod, TransitionMethod.push);
      expect(destination1.settings.transition,
          DestinationTransition.materialDialog);
    });
    test('Settings without visual effects on transition', () async {
      final destination1 = TestDestinations.aboutWithQuietSettings;
      expect(destination1.settings.transitionMethod, TransitionMethod.replace);
      expect(destination1.settings.transition, DestinationTransition.none);
    });
  });
  group('Destination Parameters', () {
    test('Reserved parameters', () {
      expect(DestinationParameters.isReservedParameter('id'), false);
      expect(DestinationParameters.isReservedParameter('state'), true);
    });
  });
}
