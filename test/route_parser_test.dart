import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import 'common/index.dart';

void main() {
  late NavigationScheme navigationScheme;

  late NavigationScheme navigationSchemeNoError;

  late TheseusRouteInformationParser parser;

  late TheseusRouteInformationParser parserNoError;

  group('TheseusRouteInformationParser', () {
    setUp(() {
      navigationScheme = NavigationScheme(
        destinations: [
          TestDestinations.home,
          TestDestinations.categoriesTyped,
          TestDestinations.about,
        ],
        errorDestination: TestDestinations.error,
      );
      navigationSchemeNoError = NavigationScheme(
        destinations: [
          TestDestinations.home,
          TestDestinations.categoriesTyped,
          TestDestinations.about,
        ],
      );
      parser = TheseusRouteInformationParser(
        navigationScheme: navigationScheme,
      );
      parserNoError = TheseusRouteInformationParser(
          navigationScheme: navigationSchemeNoError);
    });
    test('Parsing supported uri should return a destination', () async {
      expect(
          await parser
              .parseRouteInformation(const RouteInformation(location: '/home')),
          TestDestinations.home);
    });
    test('Parsing not supported uri should return an error destination',
        () async {
      expect(
          await parser.parseRouteInformation(
              const RouteInformation(location: '/home2')),
          TestDestinations.error);
    });
    test(
        'Throw exception when parsing not supported uri and error destination is not provided',
        () async {
      expect(
          () async => await parserNoError.parseRouteInformation(
              const RouteInformation(location: '/home2')),
          throwsA(isA<UnknownUriException>()));
    });
    test('Parsing supported uri which contains wrong parameter values should return an error destination',
            () async {
          expect(
              await parser.parseRouteInformation(
                  const RouteInformation(location: '/categories/10')),
              TestDestinations.error);
        });
    test(
        'Throw exception when parsing supported uri which contains wrong parameter values, and the error destination is not provided',
            () async {
          expect(
                  () async => await parserNoError.parseRouteInformation(
                  const RouteInformation(location: '/categories/10')),
              throwsA(isA<UnknownUriException>()));
        });
    test('Restore route information from the destination',
            () {
          expect(
              parser.restoreRouteInformation(TestDestinations.home).location,
              '/home');
        });
  });
}
