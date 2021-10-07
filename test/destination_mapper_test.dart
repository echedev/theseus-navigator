import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import 'common.dart';

void main() {
  final parser = const DefaultDestinationParser();

  group('Path parameter', () {
    test('Segment is path parameter', () {
      expect(parser.isPathParameter('{id}'), true);
      expect(parser.isPathParameter('{id'), false);
      expect(parser.isPathParameter('id}'), false);
      expect(parser.isPathParameter('id'), false);
    });
    test('Parse parameter name', () {
      expect(parser.parsePathParameterName('{id}'), 'id');
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
      expect(parser.isMatch('/catalog/1', destination), true);
      expect(parser.isMatch('/catalog/2', destination), true);
      expect(parser.isMatch('/catalog', destination), true);
      expect(parser.isMatch('/catalog/1?q=query', destination), true);
      expect(parser.isMatch('/catalog?q=query', destination), true);
      expect(parser.isMatch('/home/1', destination), false);
      expect(parser.isMatch('/catalog/1/search', destination), false);
    });
    test('4 segments path with 2 path parameters', () {
      final destination = TestDestinations.categoriesBrands;
      expect(parser.isMatch('/catalog/1/brands/2', destination), true);
      expect(parser.isMatch('/catalog/1/brands', destination), true);
      expect(parser.isMatch('/catalog/1/brands/2?q=query', destination), true);
      expect(parser.isMatch('/catalog/1/brands?q=query', destination), true);
      expect(parser.isMatch('/catalog/1', destination), false);
    });
  });
  group('Parse destination', () {
    test('No path parameters', () async {
      final destination1 = TestDestinations.home;
      final destination2 = TestDestinations.about;
      expect(await parser.parseParameters('/home', destination1), destination1);
      expect(await parser.parseParameters('/settings/about', destination2), destination2);
    });
    test('1 path parameter', () async {
      final destination1 = TestDestinations.categories;
      final destination2 = destination1.copyWithParameters(DefaultDestinationParameters(<String, String>{'id': '1'}));
      expect(await parser.parseParameters('/catalog', destination1) == destination1, true);
      expect(await parser.parseParameters('/catalog/1', destination1) == destination2, true);
      expect(await parser.parseParameters('/catalog/2', destination1) == destination2, false);
    });
    test('Query parameters', () async {
      final destination1 = TestDestinations.categories;
      final destination2 = destination1.copyWithParameters(DefaultDestinationParameters(<String, String>{'q': 'query'}));
      expect(await parser.parseParameters('/catalog?q=query', destination1) == destination2, true);
      expect(await parser.parseParameters('/catalog?q=1', destination1) == destination2, false);
    });
    test('Exception on not matching destination', () async {
      final destination1 = TestDestinations.home;
      expect(() async => await parser.parseParameters('/home1', destination1), throwsA(isA<DestinationNotMatchException>()));
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
      final destination1 = TestDestinations.categories.copyWithParameters(DefaultDestinationParameters(<String, String>{'id': '1'}));
      final destination2 = destination1.copyWithParameters(DefaultDestinationParameters(<String, String>{'q': 'query'}));
      final destination3 = destination1.copyWithParameters(DefaultDestinationParameters(<String, String>{'q': 'query', 'id': '2'}));
      expect(parser.uri(destination1), '/catalog/1');
      expect(parser.uri(destination2), '/catalog?q=query');
      expect(parser.uri(destination3), '/catalog/2?q=query');
    });
    test('2 path parameters with values', () {
      final destination1 = TestDestinations.categoriesBrands.copyWithParameters(DefaultDestinationParameters(<String, String>{'categoryId': '1', 'brandId': '2'}));
      expect(parser.uri(destination1), '/catalog/1/brands/2');
    });
    test('Query parameters', () {
      final destination1 = TestDestinations.categories.copyWithParameters(DefaultDestinationParameters(<String, String>{'q': 'query'}));
      final destination2 = destination1.copyWithParameters(DefaultDestinationParameters(<String, String>{'q': 'query', 'sort': 'name'}));
      expect(parser.uri(destination1), '/catalog?q=query');
      expect(parser.uri(destination2), '/catalog?q=query&sort=name');
    });
  });
}
