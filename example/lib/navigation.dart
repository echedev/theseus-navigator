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
    PrimaryDestinations.main,
    PrimaryDestinations.login,
    PrimaryDestinations.customTransition,
  ],
);

class PrimaryDestinations {
  static final login = DestinationLight(
    path: '/auth',
    builder: (context, parameters) => const LoginScreen(),
  );
  static final main = DestinationLight(
    path: '/',
    isHome: true,
    navigator: mainNavigator,
  );
  static final customTransition = DestinationLight(
    path: '/customTransition',
    builder: (context, parameters) => const CustomTransitionScreen(),
    configuration: DestinationConfiguration(
        action: DestinationAction.push,
        transition: DestinationTransition.custom,
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );
          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        }),
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
    validator: (destination) => SynchronousFuture(isLoggedIn.value),
    destination: PrimaryDestinations.login,
  );
}
