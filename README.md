#### theseus_navigator

# Theseus Navigator

Theseus Navigator package aims to simplify the implementing a navigation in your app by supporting following features:
- Declarative navigation scheme
- Strongly-typed parameters
- Deep links
- Nested and feature navigation

It provides a simple API, does not require code generation and uses Flutter's Router / Navigator 2.0 under the hood.

*Note: The package is still in progress. Any feedback, like missing features, better API suggestions, bug reports and other are appreciated.*

## Overview

The starting point of using Theseus Navigator is to define your app's navigation scheme.
It might look like this:

![NavigationScheme](./assets/NavigationScheme.jpg)

Destinations defines all possible UI endpoints in your app that users could reach using navigation.

TheseusNavigator is responsible for managing the app navigation state within the scope of its destinations. It performs navigation actions, like `goTo(destination)` and `goBack()`, and builds the navigation stack.

The NavigationScheme is the entry point to navigation and orchestrates all destinations and navigators. It has a root navigator that manages top-level destinations, and optionally additional navigators to support nested/feature navigation.

Here is an example of declaration of a simple navigation scheme:

```dart
final navigationScheme = NavigationScheme(
  destinations: [
    GeneralDestination(
      path: 'home',
      builder: (context, parameters) => HomeScreen(),
    ),
    GeneralDestination(
      path: 'orders',
      builder: (context, parameters) => OrdersScreen(),
    ),
    GeneralDestination(
      path: 'settings',
      builder: (context, parameters) => SettingsScreen(),
    ),
  ],
);
...
@override
Widget build(BuildContext context) {
  return NavigationSchemeProvider(
   scheme: navigationScheme,
   child: MaterialApp.router(
    ...
    routerDelegate: TheseusRouterDelegate(navigationScheme: navigationScheme),
    routeInformationParser: TheseusRouterInformationParser(navigationScheme: navigationScheme),
   ), ## Overview

The starting point of using Theseus Navigator is to define your app's navigation scheme.
It might look like this:

![NavigationScheme](./assets/NavigationScheme.jpg)

Destinations defines all possible UI endpoints in your app, that user could reach using navigation.  

TheseusNavigator is responsible for managing the app navigation state within the scope of its destinations. It performs navigation actions, like `goTo(destination)` and `goBack()`, and builds the navigation stack.

The NavigationScheme is the entry point to navigation and orchestrates all destinations and navigators. It has a root navigator, that manages top-level destinations, and optionally additional navigators to support nested/feature navigation.

Here is an example of declaration of a simple navigation scheme:

```dart
final navigationScheme = NavigationScheme(
  destinations: [
    GeneralDestination(
      path: 'home',
      builder: (context, parameters) => HomeScreen(),
    ),
    GeneralDestination(
      path: 'orders',
      builder: (context, parameters) => OrdersScreen(),
    ),
    GeneralDestination(
      path: 'settings',
      builder: (context, parameters) => SettingsScreen(),
    ),
  ],
);
...
@override
Widget build(BuildContext context) {
  return NavigationSchemeProvider(
   scheme: navigationScheme,
   child: MaterialApp.router(
    ...
    routerDelegate: TheseusRouterDelegate(navigationScheme: navigationScheme),
    routeInformationParser: TheseusRouterInformationParser(navigationScheme: navigationScheme),
   ),
  ),
}
```

You can navigate to a destination by this way:

```dart
onTap: () => navigationScheme.goTo(navigationScheme.findDestination('orders')),
```

  ),
}
```

You can navigate to a destination by this way:

```dart
onTap: () => navigationScheme.goTo(navigationScheme.findDestination('orders')),
```


This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
