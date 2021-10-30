import 'destination.dart';

/// Is thrown when the URI string does not match the destination.
///
class DestinationNotMatchException implements Exception {
  /// Creates exception object.
  ///
  DestinationNotMatchException(this.uri, this.destination);

  /// Source URI string.
  String uri;

  /// A destination to match the URI.
  Destination destination;
}

/// Is thrown when the navigation scheme or the navigator does not contain the destination.
///
class UnknownDestinationException implements Exception {
  /// Creates exception object.
  ///
  UnknownDestinationException([this.destination]);

  /// A destination that is not found in the navigation scheme.
  Destination? destination;
}

/// Is thrown when no destination found in the navigation scheme for given URI.
///
class UnknownUriException implements Exception {
  /// Creates exception object.
  ///
  UnknownUriException(this.uri);

  /// A URI string.
  String uri;
}
