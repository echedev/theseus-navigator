import 'package:theseus_navigator/theseus_navigator.dart';

import 'home_screen.dart';

final homeNavigator = TheseusNavigator(
  destinations: [
    HomeDestinations.home1,
    HomeDestinations.home2,
  ],
  tag: 'Home',
);

class HomeDestinations {
  static final home1 = DestinationLight(
    path: '/home1',
    builder: (context, parameters) => const HomeScreen(title: 'Home 1', next: true,),
  );

  static final home2 = DestinationLight(
    path: '/home2',
    builder: (context, parameters) => const HomeScreen(title: 'Home 2'),
  );
}
