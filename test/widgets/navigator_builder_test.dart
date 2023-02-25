import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

void main() {
  group('Default Navigator Builder', () {
    test('Default keep upward destination mode is "auto"', () {
      const navigatorBuilder = DefaultNavigatorBuilder();
      expect(
          navigatorBuilder.keepUpwardDestination ==
              KeepUpwardDestinationMode.auto,
          true);
    });
    test('Explicit keep upward destination mode', () {
      const navigatorBuilder = DefaultNavigatorBuilder(
          keepUpwardDestinationMode: KeepUpwardDestinationMode.always);
      expect(
          navigatorBuilder.keepUpwardDestination ==
              KeepUpwardDestinationMode.always,
          true);
    });
  });
}
