import 'package:flutter/material.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

import 'navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Theseus Navigator Demo',
      theme: Theme.of(context).copyWith(
        primaryColor: Colors.blueGrey,
        accentColor: Colors.amber,
        toggleableActiveColor: Colors.amber,
        dividerColor: Colors.transparent,
      ),
      routerDelegate: TheseusRouterDelegate(
        navigationScheme: navigationScheme,
      ),
      routeInformationParser: TheseusRouteInformationParser(
        navigationScheme: navigationScheme,
      ),
    );
  }
}
