import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_test/flutter_test.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

import 'common/index.dart';

void main() {
  const parser = DefaultDestinationParser();

  final categoriesParser = CategoriesParser();

  group('Destination Parser', () {
    group('Path parameter', () {
      test('Segment is path parameter', () {
        expect(parser.isPathParameter('{id}'), true);
        expect(parser.isPathParameter('{id'), false);
        expect(parser.isPathParameter('id}'), false);
        expect(parser.isPathParameter('id'), false);
      });
      test('Parse parameter name', () {
        expect(parser.parsePathParameterName('{id}'), 'id');
        expect(() => parser.parsePathParameterName(':id'), throwsA(isA<Exception>()));
      });
    });
    group('Matching URI', () {
      test('1 segment path', () {
        final destination = TestDestinations.home;
        expect(parser.isMatch('/home', destination), true);
        expect(parser.isMatch('/home1', destination), false);
        expect(parser.isMatch('/home/1', destination), false);
      });
      test('2 segments path', () {
        final destination = TestDestinations.about;
        expect(parser.isMatch('/settings/about', destination), true);
        expect(parser.isMatch('/settings/about?q=query', destination), true);
        expect(parser.isMatch('/settings', destination), false);
        expect(parser.isMatch('/home/about', destination), false);
        expect(parser.isMatch('/settings/profile', destination), false);
      });
      test('2 segments path with path parameter', () {
        final destination = TestDestinations.categories;
        expect(parser.isMatch('/categories/1', destination), true);
        expect(parser.isMatch('/categories/2', destination), true);
        expect(parser.isMatch('/categories', destination), true);
        expect(parser.isMatch('/categories/1?q=query', destination), true);
        expect(parser.isMatch('/categories?q=query', destination), true);
        expect(parser.isMatch('/home/1', destination), false);
        expect(parser.isMatch('/categories/1/search', destination), false);
      });
      test('4 segments path with 2 path parameters', () {
        final destination = TestDestinations.categoriesBrands;
        expect(parser.isMatch('/categories/1/brands/2', destination), true);
        expect(parser.isMatch('/categories/1/brands', destination), true);
        expect(parser.isMatch('/categories/1/brands/2?q=query', destination),
            true);
        expect(
            parser.isMatch('/categories/1/brands?q=query', destination), true);
        expect(parser.isMatch('/categories/1', destination), false);
      });
    });
    group('Parsing parameters', () {
      test('No path parameters', () async {
        final destination1 = TestDestinations.home;
        final destination2 = TestDestinations.about;
        expect(
            await parser.parseParameters('/home', destination1), destination1);
        expect(await parser.parseParameters('/settings/about', destination2),
            destination2);
      });
      test('1 path parameter', () async {
        final destination1 = TestDestinations.categories;
        final destination2 = destination1
            .withParameters(DestinationParameters(<String, String>{'id': '1'}));
        expect(
            await parser.parseParameters('/categories', destination1) ==
                destination1,
            true);
        expect(
            await parser.parseParameters('/categories/1', destination1) ==
                destination2,
            true);
        expect(
            await parser.parseParameters('/categories/2', destination1) ==
                destination2,
            false);
      });
      test('1 path parameter - Typed parameters', () async {
        final destination1 = TestDestinations.categoriesTyped;
        const parentCategory1 = Category(id: 1, name: 'Category 1');
        final destination2 = destination1
            .withParameters(CategoriesParameters(parent: parentCategory1));
        final result1 =
            await categoriesParser.parseParameters('/categories', destination1);
        expect(result1 == destination1, true);
        final result2 = await categoriesParser.parseParameters(
            '/categories/1', destination1);
        expect(result2 == destination2, true);
        expect(result2.parameters is CategoriesParameters, true);
        expect(result2.parameters!.map.isNotEmpty, true);
        expect(
            mapEquals(
                result2.parameters!.map, <String, String>{'parentId': '1'}),
            true);
        final result3 = await categoriesParser.parseParameters(
            '/categories/2', destination1);
        expect(result3 == destination2, false);
      });
      test('Query parameters', () async {
        final destination1 = TestDestinations.categories;
        final destination2 = destination1.withParameters(
            DestinationParameters(<String, String>{'q': 'query'}));
        expect(
            await parser.parseParameters('/categories?q=query', destination1) ==
                destination2,
            true);
        expect(
            await parser.parseParameters('/categories?q=1', destination1) ==
                destination2,
            false);
      });
      test('Query parameters - Clear unused for typed parameters', () async {
        final destination1 = TestDestinations.categoriesTyped;
        const parentCategory1 = Category(id: 1, name: 'Category 1');
        final destination2 = destination1
            .withParameters(CategoriesParameters(parent: parentCategory1));
        final result = await categoriesParser.parseParameters(
            '/categories/1?q=query', destination2);
        expect(result.parameters is CategoriesParameters, true);
        expect(result.parameters!.map.isNotEmpty, true);
        expect(
            mapEquals(result.parameters!.map, <String, String>{
              'parentId': '1',
            }),
            true);
      });
      test('Query parameters - Keep reserved parameters - state', () async {
        final destination1 = TestDestinations.categoriesTyped;
        const parentCategory1 = Category(id: 1, name: 'Category 1');
        final destination2 = destination1
            .withParameters(CategoriesParameters(parent: parentCategory1));
        final result = await categoriesParser.parseParameters(
            '/categories/1?state=/settings/about', destination2);
        expect(result.parameters is CategoriesParameters, true);
        expect(result.parameters!.map.isNotEmpty, true);
        expect(
            mapEquals(result.parameters!.map, <String, String>{
              'parentId': '1',
              'state': TestDestinations.about.path
            }),
            true);
      });
      test('Exception on not matching destination', () async {
        final destination1 = TestDestinations.home;
        expect(() async => await parser.parseParameters('/home1', destination1),
            throwsA(isA<DestinationNotMatchException>()));
      });
    });
    group('Generate destination URI', () {
      test('No path parameters', () {
        final destination1 = TestDestinations.home;
        final destination2 = TestDestinations.about;
        expect(parser.uri(destination1), '/home');
        expect(parser.uri(destination2), '/settings/about');
      });
      test('1 path parameter with value', () {
        final destination1 = TestDestinations.categories
            .withParameters(DestinationParameters(<String, String>{'id': '1'}));
        final destination2 = destination1.withParameters(
            DestinationParameters(<String, String>{'q': 'query'}));
        final destination3 = destination1.withParameters(
            DestinationParameters(<String, String>{'q': 'query', 'id': '2'}));
        expect(parser.uri(destination1), '/categories/1');
        expect(parser.uri(destination2), '/categories?q=query');
        expect(parser.uri(destination3), '/categories/2?q=query');
      });
      test('2 path parameters with values', () {
        final destination1 = TestDestinations.categoriesBrands.withParameters(
            DestinationParameters(
                <String, String>{'categoryId': '1', 'brandId': '2'}));
        expect(parser.uri(destination1), '/categories/1/brands/2');
      });
      test('Query parameters', () {
        final destination1 = TestDestinations.categories.withParameters(
            DestinationParameters(<String, String>{'q': 'query'}));
        final destination2 = destination1.withParameters(DestinationParameters(
            <String, String>{'q': 'query', 'sort': 'name'}));
        expect(parser.uri(destination1), '/categories?q=query');
        expect(parser.uri(destination2), '/categories?q=query&sort=name');
      });
    });
  });
}
