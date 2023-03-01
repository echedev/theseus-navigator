import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

void main() {
  group('Default Navigator Builder', () {
    test('Default keep upward destination mode is "auto"', () {
      const navigatorBuilder = DefaultNavigatorBuilder();
      expect(
          navigatorBuilder.keepStateInParameters ==
              KeepingStateInParameters.auto,
          true);
    });
    test('Explicit keep upward destination mode', () {
      const navigatorBuilder = DefaultNavigatorBuilder(
          keepStateInParameters: KeepingStateInParameters.always);
      expect(
          navigatorBuilder.keepStateInParameters ==
              KeepingStateInParameters.always,
          true);
    });
  });
}
