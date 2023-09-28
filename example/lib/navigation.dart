// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

import 'auth/index.dart';
import 'catalog/index.dart';
import 'error/index.dart';
import 'home/index.dart';
import 'settings/index.dart';

final navigationScheme = NavigationScheme(
  destinations: [
    PrimaryDestinations.login,
    PrimaryDestinations.main,
    PrimaryDestinations.customTransition,
  ],
  errorDestination: PrimaryDestinations.error,
);

class PrimaryDestinations {
  static final login = Destination(
    path: '/auth',
    builder: (context, parameters) => const LoginScreen(),
  );
  static final main = Destination(
    path: '/main',
    isHome: true,
    navigator: mainNavigator,
  );
  static final customTransition = Destination(
    path: '/customTransition',
    builder: (context, parameters) => const CustomTransitionScreen(),
    settings: DestinationSettings(
        transitionMethod: TransitionMethod.push,
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
  static final error = Destination(
    path: '/error',
    builder: (context, parameters) => const ErrorScreen(),
  );
}

final mainNavigator = NavigationController(
  destinations: [
    MainDestinations.home,
    MainDestinations.catalog,
    MainDestinations.settings,
  ],
  builder: MainNavigatorBuilder(),
  tag: 'Main',
);

class MainDestinations {
  static final home = Destination(
    path: '/home',
    navigator: homeNavigator,
    settings: DestinationSettings.quiet(),
  );
  static final catalog = Destination(
    path: '/catalog',
    navigator: catalogNavigator,
    settings: DestinationSettings.quiet(),
  );
  static final settings = Destination(
    path: '/settings',
    builder: (context, parameters) => const SettingsScreen(),
    settings: DestinationSettings.quiet(),
    redirections: [
      Redirections.login,
    ],
  );
}

class MainNavigatorBuilder extends NavigatorBuilder {
  @override
  Widget build(BuildContext context, NavigationController navigator) {
    return _MainNavigatorWrapper(navigator: navigator);
  }
}

class _MainNavigatorWrapper extends StatelessWidget {
  const _MainNavigatorWrapper({
    Key? key,
    required this.navigator,
  }) : super(key: key);

  final NavigationController navigator;

  static const bottomNavigationBuilder = BottomNavigationBuilder(
    bottomNavigationItems: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.list_rounded),
        label: 'Catalog',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.more_horiz_rounded),
        label: 'Settings',
      ),
    ],
  );

  static final bottomNavigationBuilderMaterial3 =
      BottomNavigationBuilder.navigationBar(
    navigationBarItems: const <NavigationDestination>[
      NavigationDestination(
        icon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.list_rounded),
        label: 'Catalog',
      ),
      NavigationDestination(
        icon: Icon(Icons.more_horiz_rounded),
        label: 'Settings',
      ),
    ],
  );

  static const drawerNavigationBuilder = DrawerNavigationBuilder(
      drawerItems: <DrawerItem>[
        DrawerItem(
          leading: Icon(Icons.home_rounded),
          title: 'Home',
        ),
        DrawerItem(
          leading: Icon(Icons.list_rounded),
          title: 'Catalog',
        ),
        DrawerItem(
          leading: Icon(Icons.more_horiz_rounded),
          title: 'Settings',
        ),
      ],
      parameters: DrawerParameters(
        selectedColor: Colors.blue,
      ));

  static const tabsNavigationBuilder = TabsNavigationBuilder(
    tabs: <Widget>[
      Tab(
        icon: Icon(Icons.home_rounded),
        child: Text('Home'),
      ),
      Tab(
        icon: Icon(Icons.list_rounded),
        child: Text('Catalog'),
      ),
      Tab(
        icon: Icon(Icons.more_horiz_rounded),
        child: Text('Settings'),
      ),
    ],
    wrapInScaffold: true,
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TopLevelNavigationType>(
      valueListenable: topLevelNavigationType,
      builder: (context, value, child) {
        switch (value) {
          case TopLevelNavigationType.bottom:
            return bottomNavigationBuilder.build(context, navigator);
          case TopLevelNavigationType.bottomMaterial3:
            return bottomNavigationBuilderMaterial3.build(context, navigator);
          case TopLevelNavigationType.drawer:
            return drawerNavigationBuilder.build(context, navigator);
          case TopLevelNavigationType.tabs:
            return tabsNavigationBuilder.build(context, navigator);
        }
      },
    );
  }
}

class Redirections {
  static final login = Redirection(
    // validator: (destination) => SynchronousFuture(isLoggedIn.value),
    validator: (destination) =>
        Future.delayed(const Duration(seconds: 3), () => isLoggedIn.value),
    destination: PrimaryDestinations.login.withSettings(
        PrimaryDestinations.login.settings.copyWith(updateHistory: false)),
  );
}
