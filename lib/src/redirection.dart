import 'destination.dart';
import 'utils/log/log.dart';

/// Defines a redirection.
///
/// Uses [validator] function to determine if it is allowed to navigate to the
/// given destination.
/// If it is not, user will be redirected to either a provided fixed [destination],
/// or to a destination returned by [resolver] function.
///
/// You can extend this class and override its [validate] and [resolve] methods
/// to implement more complex logic of redirection.
///
/// See also:
/// - [NavigationScheme]
/// - [Destination]
///
class Redirection {
  /// Creates a redirection.
  ///
  const Redirection({
    this.destination,
    this.resolver,
    this.validator,
  }) : assert(destination != null || resolver != null,
            'Either "destination" or "resolver" must be specified.');

  /// Destination to redirect.
  ///
  final Destination? destination;

  /// Identifies a destination to redirect.
  ///
  /// Implements a logic of dynamic resolving a destination for redirection.
  ///
  /// Consider to use fixed [destination] instead of this function, if dynamic
  /// resolving is not needed.
  ///
  final Future<Destination> Function(Destination destination)? resolver;

  /// Validates a destination.
  ///
  /// Must return true if it is allowed to navigate to the destination.
  /// Otherwise returns false.
  ///
  /// If validation could be performed synchronously consider return result with
  /// [SynchronousFuture].
  ///
  final Future<bool> Function(Destination destination)? validator;

  /// Validates the destination.
  ///
  /// [NavigationScheme] uses this method to check if it is needed to redirect to
  /// another destination.
  ///
  Future<bool> validate(Destination destination) async {
    final result = await validator?.call(destination) ?? false;
    Log.d(runtimeType, 'validate(): $result');
    return result;
  }

  /// Destination to redirect
  ///
  /// Return either a fixed [destination], or call [resolver] to evaluate a destiantion
  /// to redirect.
  ///
  Future<Destination> resolve(Destination destination) async {
    final result = this.destination ?? (await resolver!.call(destination));
    Log.d(runtimeType, 'resolve(): $result');
    return result;
  }
}
