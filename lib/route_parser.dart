import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:theseus_navigator/navigator.dart';
import 'package:utils/utils.dart';

import 'destination.dart';
import 'exceptions.dart';
import 'navigation_scheme.dart';

/// Implementation of [RouteInformationParser].
///
/// Uses [navigationScheme] to get access to route's information.
///
/// See also:
/// - [NavigationScheme]
/// - [TheseusNavigator]
/// - [Destination]
///
class TheseusRouteInformationParser extends RouteInformationParser<Destination> {
  TheseusRouteInformationParser({
    required this.navigationScheme,
  });

  final NavigationScheme navigationScheme;

  @override
  Future<Destination> parseRouteInformation(RouteInformation routeInformation) {
    final uri = routeInformation.location ?? '';
    Log.d(runtimeType, 'parseRouteInformation(): $uri');
    final baseDestination = navigationScheme.findDestination(uri);
    if (baseDestination == null) {
      throw UnknownUriException(uri);
    }
    return baseDestination.parse(uri);
  }
}