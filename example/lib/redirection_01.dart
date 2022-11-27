import 'package:flutter/material.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

void main() => runApp(const App());

class Destinations {
  static final home = Destination(
    path: '/home',
    isHome: true,
    builder: (context, parameters) => const HomeScreen(),
  );
  static final settings = Destination(
    path: '/settings',
    builder: (context, parameters) => const SettingsScreen(),
    redirections: [
      Redirection(
        validator: (destination) async {
          await Future.delayed(const Duration(seconds: 3));
          return isLoggedIn;
        },
        destination: login,
      ),
    ],
  );
  static final login = Destination(
    path: '/login',
    builder: (context, parameters) => const LoginScreen(),
  );
}

final navigationScheme = NavigationScheme(
  destinations: [
    Destinations.home,
    Destinations.settings,
    Destinations.login,
  ],
  waitingOverlayBuilder: (context, destination) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  },
);

bool isLoggedIn = false;

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: navigationScheme.routerDelegate,
      routeInformationParser: navigationScheme.routeParser,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                navigationScheme.goTo(Destinations.settings);
              },
              child: const Text('Settings'),
            ),
            ElevatedButton(
              onPressed: () {
                navigationScheme.goTo(Destinations.login);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings screen')),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            isLoggedIn = !isLoggedIn;
            navigationScheme.goBack();
          },
          child: Text(isLoggedIn ? 'Log Out' : 'Log In'),
        ),
      ),
    );
  }
}
