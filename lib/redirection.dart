import 'package:theseus_navigator/router_delegate.dart';
import 'package:theseus_navigator/utils/log/log.dart';

import 'destination.dart';

/// Defines a redirection.
///
/// Uses [validator] function to determine if it is allowed to navigate to the
/// given destination.
/// If it is not, user will be redirected to a provided new [destination]
/// on navigation to given destination.
///
/// You can extend this class and override its [validate()] method to implement
/// more complex logic of validation.
///
/// See also:
/// - [TheseusRouterDelegate]
/// - [Destination]
///
class Redirection {
  /// Creates a redirection.
  ///
  const Redirection({
    this.validator,
    required this.destination,
  });

  /// Should implement a logic to validate a destination.
  ///
  /// Must return true if it is allowed to navigate to the destination.
  /// Otherwise returns false.
  ///
  final Future<bool> Function(Destination destination)? validator;

  /// Destination to redirect.
  ///
  final Destination destination;

  /// Validates the destination.
  ///
  /// [TheseusRouterDelegate] uses this method to check if it is needed to redirect to
  /// another destination.
  ///
  Future<bool> validate(Destination destination) async {
    final result = await validator?.call(destination) ?? false;
    Log.d(runtimeType, 'validate(): $result');
    return result;
  }
}
