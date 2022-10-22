import 'package:flutter_test/flutter_test.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import 'common/common.dart';

void main() {
  group('Redirection', () {
    test('Validation successful', () async {
      final redirection = Redirection(
        destination: TestDestinations.login,
        validator: (destination) async => true,
      );
      expect(await redirection.validate(TestDestinations.home), true);
    });
    test('Validation failed', () async {
      final redirection = Redirection(
        destination: TestDestinations.login,
        validator: (destination) async => false,
      );
      expect(await redirection.validate(TestDestinations.home), false);
    });
    test('No validator function should fail validation', () async {
      final redirection = Redirection(
        destination: TestDestinations.login,
      );
      expect(await redirection.validate(TestDestinations.home), false);
    });
  });
}
