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
    final uri = routeInformation.uri.toString();
    Log.d(runtimeType, 'parseRouteInformation(): uri=$uri');
    final matchedDestination = navigationScheme.findDestination(uri);
    if (matchedDestination == null) {
      if (navigationScheme.errorDestination != null) {
        return SynchronousFuture(navigationScheme.errorDestination!);
      } else {
        throw UnknownUriException(uri);
      }
    }
    try {
      final result = await matchedDestination.parse(uri);
      Log.d(runtimeType, 'parseRouteInformation(): destination=$result');
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
  RouteInformation? restoreRouteInformation(Destination destination) {
    if (!destination.settings.updateHistory) {
      Log.d(runtimeType,
          'restoreRouteInformation(): Would not restore route information for ${destination.uri}');
      return null;
    }
    final uri = Uri.parse(Uri.decodeComponent(destination.uri));
    Log.d(runtimeType, 'restoreRouteInformation(): $uri');
    return RouteInformation(uri: uri);
  }
}
