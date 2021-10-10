import 'package:flutter/widgets.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

import 'catalog/index.dart';
import 'home/index.dart';
import 'main_screen.dart';
import 'settings/index.dart';

final navigationScheme = NavigationScheme(
  navigator: mainNavigator,
);

final mainNavigator = TheseusNavigator(
  destinations: [
    MainDestinations.home,
    MainDestinations.catalog,
    MainDestinations.settings,
  ],
  builder: MainNavigatorBuilder(),
);

class MainNavigatorBuilder implements NavigatorBuilder {
  @override
  Widget build(BuildContext context, TheseusNavigator navigator) {
    final currentDestination = navigator.currentDestination;
    final content = currentDestination.build(context);
    return MainScreen(
      content: content,
      onSelectBottomTab: (index) => navigator.goTo(navigator.destinations[index]),
      selectedIndex: navigator.destinations.indexOf(currentDestination),
    );
  }
}

class MainDestinations {
  static final home = DestinationLight(
    path: '/home',
    isHome: true,
    builder: (context, parameters) => HomeScreen(),
    configuration: DestinationConfiguration.quiet(),
  );
  static final catalog = DestinationLight(
    path: '/catalog',
    navigator: catalogNavigator,
    configuration: DestinationConfiguration.quiet(),
  );
  static final settings = DestinationLight(
    path: '/settings',
    builder: (context, parameters) => SettingsScreen(),
    configuration: DestinationConfiguration.quiet(),
  );
}