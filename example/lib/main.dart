// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

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
        toggleableActiveColor: Colors.amber,
        dividerColor: Colors.transparent,
        colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.blueGrey,
            secondary: Colors.amber,
            secondaryContainer: Colors.blue,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.amber,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.blueGrey,
        )
      ),
      routerDelegate: navigationScheme.routerDelegate,
      routeInformationParser: navigationScheme.routeParser,
    );
  }
}
