import 'package:flutter/material.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

void main() => runApp(const App());

final navigationScheme = NavigationScheme(
  destinations: [
    MainDestinations.screen1,
    MainDestinations.screen2,
    MainDestinations.screen3,
    MainDestinations.screen4,
    MainDestinations.screen5,
  ],
);

class MainDestinations {
  static final screen1 = Destination(
    path: '/screen1',
    isHome: true,
    builder: (context, parameters) => const Screen1(),
  );

  static final screen2 = Destination(
    path: '/screen2',
    builder: (context, parameters) => const Screen2(),
  );

  static final screen3 = Destination(
    path: '/screen3',
    builder: (context, parameters) => const Screen3(),
  );

  static final screen4 = Destination(
    path: '/screen4',
    builder: (context, parameters) => const Screen4(),
  );

  static final screen5 = Destination(
    path: '/screen5',
    builder: (context, parameters) => const Screen5(),
    upwardDestinationBuilder: (destination) async => screen4,
  );
}

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

class Screen1 extends StatelessWidget {
  const Screen1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen 1'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen2),
              child: const Text('to Screen 2'),
            ),
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen3),
              child: const Text('to Screen 3'),
            ),
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen4),
              child: const Text('to Screen 4'),
            ),
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen5),
              child: const Text('to Screen 5'),
            ),
          ],
        ),
      ),
    );
  }
}

class Screen2 extends StatelessWidget {
  const Screen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen 2'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen1),
              child: const Text('to Screen 1'),
            ),
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen3),
              child: const Text('to Screen 3'),
            ),
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen4),
              child: const Text('to Screen 4'),
            ),
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen5),
              child: const Text('to Screen 5'),
            ),
          ],
        ),
      ),
    );
  }
}

class Screen3 extends StatelessWidget {
  const Screen3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen 3'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen1),
              child: const Text('to Screen 1'),
            ),
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen2),
              child: const Text('to Screen 2'),
            ),
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen4),
              child: const Text('to Screen 4'),
            ),
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen5),
              child: const Text('to Screen 5'),
            ),
          ],
        ),
      ),
    );
  }
}

class Screen4 extends StatelessWidget {
  const Screen4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen 4 - Parent'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => navigationScheme.goTo(MainDestinations.screen5),
              child: const Text('to Screen 5 (child)'),
            ),
          ],
        ),
      ),
    );
  }
}

class Screen5 extends StatelessWidget {
  const Screen5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen 5 - Child'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          ],
        ),
      ),
    );
  }
}
