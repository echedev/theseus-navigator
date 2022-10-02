import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:theseus_navigator/src/navigation_controller.dart';

import 'destination.dart';
import 'exceptions.dart';
import 'navigation_scheme.dart';
import 'utils/utils.dart';

/// Implementation of [RouteInformationParser].
///
/// Uses [navigationScheme] to get access to route's information.
///
/// See also:
/// - [NavigationScheme]
/// - [NavigationController]
/// - [Destination]
///
class TheseusRouteInformationParser
    extends RouteInformationParser<Destination> {
  /// Creates a route information parser.
  ///
  TheseusRouteInformationParser({
    required this.navigationScheme,
  });

  /// A navigation scheme that contains destinations to parse.
  ///
  final NavigationScheme navigationScheme;

  @override
  Future<Destination> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = routeInformation.location ?? '';
    Log.d(runtimeType, 'parseRouteInformation(): $uri');
    final baseDestination = navigationScheme.findDestination(uri);
    if (baseDestination == null) {
      if (navigationScheme.errorDestination != null) {
        return SynchronousFuture(navigationScheme.errorDestination!);
      } else {
        throw UnknownUriException(uri);
      }
    }
    try {
      final result = await baseDestination.parse(uri);
      return result;
    } catch (error) {
      if (navigationScheme.errorDestination != null) {
        return SynchronousFuture(navigationScheme.errorDestination!);
      } else {
        throw UnknownUriException(uri);
      }
    }
  }

  @override
  // ignore: avoid_renaming_method_parameters
  RouteInformation restoreRouteInformation(Destination destination) {
    return RouteInformation(location: destination.uri);
  }
}
