import 'package:flutter/foundation.dart';

import 'destination.dart';
import 'exceptions.dart';

/// A base destination parser.
///
/// [DestinationParser] object is used to parse the destination object from the
/// give URI string, and to generate the URI for the destination.
///
/// When subclassed, the certain type of destination parameters must be provided.
///
/// There are two methods, that must be implemented in the specific parser:
/// [toDestinationParameters] and [toMap].
///
/// If typed parameters are not required, the [DefaultDestinationParser] is used.
///
/// See also:
/// - [Destination]
/// - [DestinationParameters]
/// - [DefaultDestinationParameters]
/// - [DefaultDestinationParser]
///
abstract class DestinationParser<T extends DestinationParameters> {
  /// Creates destination parser.
  ///
  const DestinationParser();

  /// Creates a destination parameters object of type [T] from the given map.
  ///
  /// The key of the map entry is a parameter name, and the value is serialized
  /// parameter's value.
  /// This method is used by [parseParameters()] to generate the destination object
  /// from the given URI string.
  ///
  Future<T> toDestinationParameters(Map<String, String> map);

  /// Converts destination [parameters] object of type [T] to a map.
  ///
  /// The key of the map entry is a parameter name, and the value is serialized
  /// parameter's value.
  /// This method is used by [uri()] to generate the destination's URI string.
  ///
  Map<String, String> toMap(T parameters);

  /// Check if the provided [uri] string match the base [destination]
  ///
  bool isMatch(String uri, Destination<T> destination) {
    if ((uri == '/' || uri.isEmpty)) {
      return destination.isHome;
    }

    final destinationUri = Uri.parse(destination.path);
    final sourceUri = Uri.parse(uri);
    final destinationSegments = destinationUri.pathSegments;
    final sourceSegments = sourceUri.pathSegments;

    if (destinationSegments.length < sourceSegments.length) {
      return false;
    }
    final lengthDifference = destinationSegments.length - sourceSegments.length;
    if (lengthDifference > 1 ||
        lengthDifference == 1 && !isPathParameter(destinationSegments.last)) {
      return false;
    }
    for (var i = 0; i < destinationSegments.length - lengthDifference; i++) {
      if (destinationSegments[i] != sourceSegments[i] &&
          !isPathParameter(destinationSegments[i])) {
        return false;
      }
    }
    return true;
  }

  /// Check if the path segment string is a valid path parameter template.
  ///
  /// The default path parameter format is '{parameterName}'.
  ///
  bool isPathParameter(String pathSegment) {
    return pathSegment.startsWith('{') && pathSegment.endsWith('}');
  }

  /// Extract parameter name from the path segment string.
  ///
  /// See [isPathParameter] for default path parameter format.
  ///
  String parsePathParameterName(String pathSegment) {
    if (!isPathParameter(pathSegment)) {
      throw Exception('$pathSegment is not a valid path parameter');
    }
    return pathSegment.substring(1, pathSegment.length - 1);
  }

  /// Parse parameter values from the specified URI and based on provided destination template.
  ///
  /// Returns the copy of [baseDestination] with parameters parsed from the [uri].
  /// Uses [toDestinationParameters] implementation to create the certain [DestinationParameters].
  /// Throws [DestinationNotMatchException] if the URI does mot match base destination.
  ///
  Future<Destination<T>> parseParameters(
      String uri, Destination<T> baseDestination) async {
    if (!isMatch(uri, baseDestination)) {
      throw DestinationNotMatchException(uri, baseDestination);
    }
    final destinationUri = Uri.parse(uri);
    final parametersMap = <String, String>{};
    parametersMap
        .addAll(_parseUriPathParameters(destinationUri, baseDestination));
    parametersMap.addAll(destinationUri.queryParameters);
    return baseDestination
        .copyWithParameters(await toDestinationParameters(parametersMap));
  }

  /// Returns URI string for the destination
  ///
  /// The [Destination.path] is used for building the URI path segment.
  /// The URI query segment is built using [Destination.parameters] converted
  /// by [toMap] implementation from the [Destination.parser].
  ///
  String uri(Destination destination) {
    late final Map<String, String> parametersMap;
    if (destination.parameters == null) {
      parametersMap = const <String, String>{};
    } else {
      parametersMap = destination.parser.toMap(destination.parameters!);
    }
    final pathParameters = _getPathParameters(destination.path, parametersMap);
    final queryParameters = _getQueryParameters(pathParameters, parametersMap);
    final path = _fillPathParameters(destination.path, pathParameters);
    return Uri(
      path: path,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    ).toString();
  }

  Map<String, String> _parseUriPathParameters(
      Uri uri, Destination<T> baseDestination) {
    final result = <String, String>{};
    final baseDestinationUri = Uri.parse(baseDestination.path);
    for (int i = 0; i < uri.pathSegments.length; i++) {
      final pathSegment = uri.pathSegments[i];
      final baseDestinationPathSegment = baseDestinationUri.pathSegments[i];
      if (isPathParameter(baseDestinationPathSegment)) {
        final parameterName =
            parsePathParameterName(baseDestinationPathSegment);
        result[parameterName] = pathSegment;
      }
    }
    return result;
  }

  Map<String, String> _getPathParameters(
      String path, Map<String, String> parameters) {
    final result = <String, String>{};
    final pathUri = Uri.parse(path);
    for (var pathSegment in pathUri.pathSegments) {
      if (isPathParameter(pathSegment)) {
        final parameterName = parsePathParameterName(pathSegment);
        final value = parameters[parameterName];
        if (value != null) {
          result[parameterName] = value;
        }
      }
    }
    return result;
  }

  Map<String, String> _getQueryParameters(
      Map<String, String> pathParameters, Map<String, String> parameters) {
    final result = <String, String>{};
    for (MapEntry entry in parameters.entries) {
      if (pathParameters.keys.contains(entry.key)) {
        continue;
      }
      result[entry.key] = entry.value;
    }
    return result;
  }

  String _fillPathParameters(String path, Map<String, String> parameters) {
    final pathUri = Uri.parse(path);
    final filledPathSegments = <String>[];
    for (var pathSegment in pathUri.pathSegments) {
      if (isPathParameter(pathSegment)) {
        final parameterName = parsePathParameterName(pathSegment);
        final value = parameters[parameterName];
        if (value != null) {
          filledPathSegments.add(value);
        } else {
          if (pathUri.pathSegments.last != pathSegment) {
            filledPathSegments.add(pathSegment);
          }
        }
      } else {
        filledPathSegments.add(pathSegment);
      }
    }
    final result = Uri(pathSegments: filledPathSegments).toString();
    return '${path.startsWith('/') ? "/" : ""}$result';
  }
}

/// A default implementation of [DestinationParser].
///
class DefaultDestinationParser
    extends DestinationParser<DefaultDestinationParameters> {
  /// Creates default destination parser.
  ///
  const DefaultDestinationParser() : super();

  @override
  Future<DefaultDestinationParameters> toDestinationParameters(
          Map<String, String> map) =>
      SynchronousFuture(DefaultDestinationParameters(map));

  @override
  Map<String, String> toMap(DefaultDestinationParameters parameters) =>
      parameters.map;
}
