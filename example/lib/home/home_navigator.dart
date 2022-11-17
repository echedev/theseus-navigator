import 'package:theseus_navigator/theseus_navigator.dart';

import 'home_dialog.dart';
import 'home_screen.dart';

final homeNavigator = NavigationController(
  destinations: [
    HomeDestinations.home1,
    HomeDestinations.home2,
    HomeDestinations.dialog,
  ],
  tag: 'Home',
);

class HomeDestinations {
  static final home1 = Destination(
    path: '/home1',
    builder: (context, parameters) => const HomeScreen(
      title: 'Home 1',
      next: true,
    ),
  );

  static final home2 = Destination(
    path: '/home2',
    builder: (context, parameters) => const HomeScreen(title: 'Home 2'),
  );

  static final dialog = Destination(
    path: '/dialog',
    builder: (context, parameters) => const HomeDialog(
      title: 'Dialog',
      message: 'This destination is shown as a dialog.',
    ),
    configuration: DestinationConfiguration.dialog(),
  );
}
