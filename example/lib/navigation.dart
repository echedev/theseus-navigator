// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

import 'auth/index.dart';
import 'catalog/index.dart';
import 'home/index.dart';
import 'main_screen.dart';
import 'settings/index.dart';

final navigationScheme = NavigationScheme(
  destinations: [
    TopLevelDestinations.main,
    TopLevelDestinations.login,
  ],
);

class TopLevelDestinations {
  static final login = DestinationLight(
    path: '/auth',
    builder: (context, parameters) => const LoginScreen(),
  );
  static final main = DestinationLight(
    path: '/',
    isHome: true,
    navigator: mainNavigator,
  );
}

final mainNavigator = TheseusNavigator(
  destinations: [
    MainDestinations.home,
    MainDestinations.catalog,
    MainDestinations.settings,
  ],
  builder: MainNavigatorBuilder(),
  debugLabel: 'Main',
);

class MainNavigatorBuilder implements NavigatorBuilder {
  @override
  Widget build(BuildContext context, TheseusNavigator navigator) {
    final currentDestination = navigator.currentDestination;
    final content = currentDestination.build(context);
    return MainScreen(
      content: content,
      onSelectBottomTab: (index) =>
          navigator.goTo(navigator.destinations[index]),
      selectedIndex: navigator.destinations.indexOf(currentDestination),
    );
  }
}

class MainDestinations {
  static final home = DestinationLight(
    path: '/home',
    builder: (context, parameters) => const HomeScreen(),
    configuration: DestinationConfiguration.quiet(),
  );
  static final catalog = DestinationLight(
    path: '/catalog',
    navigator: catalogNavigator,
    configuration: DestinationConfiguration.quiet(),
  );
  static final settings = DestinationLight(
    path: '/settings',
    builder: (context, parameters) => const SettingsScreen(),
    configuration: DestinationConfiguration.quiet(),
    redirections: [
      Redirections.login,
    ],
  );
}

class Redirections {
  static final login = Redirection(
    validator: (destination) => SynchronousFuture(isLoggedIn),
    destination: TopLevelDestinations.login,
  );
}
