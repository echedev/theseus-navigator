---
layout: post
title:  "Persistence of the navigation state"
date:   2023-03-04 14:00:00 +0300
tags: navigation state
---
Persisting navigation state is one of core features of the [Theseus Navigator](https://pub.dev/packages/theseus_navigator) package.

For example, if you have a bottom navigation bar for primary destinations and each tab has its own nested navigation, the stack of pages of each tab persists when you switch to another tab.

>You can check this [recipe](https://echedev.github.io/theseus-navigator/cookbook/bottom-navigation-bar) for implementing bottom navigation with Theseus Navigator.

This behavior is supported on all platforms - mobile, desktop and web. 

However, there was no support for automatic restoration of the navigation state by a deep link. Particularly, this caused confusing behavior while navigating back and forward in a web browser history.

You still were able to implement state restoration from the deep link manually, by using the custom `upwardDestinationBuilder` function, which allows you to build a custom stack of pages. But for a complex navigation scheme it could be a tricky tas.

Since **version 0.6.0** Theseus Navigator supports automatic saving and restoration of the full navigation stack in the destination parameters.

The `keepStateInParameters` property, which controls this behavior, is added to a `NavigatorBuilder`. The parameter can take `always`, `auto` or `none` values. 

By default, the `auto` mode is set, which means that the navigation state will be persisted in the parameters only when the app is running on the web platform.

In case if you need automatic persisting of the navigation state in destination parameters on all platforms, you should setup your navigation controller like this:
``` dart
navigationScheme = NavigationScheme(
  navigator: NavigationController(
    destinations: [
      // ...
    ],
    builder: const DefaultNavigatorBuilder(
      keepStateInParameters: keepingStateInParameters.always,
    ),
  ),
);

```

You can check the persistence of the navigation state feature in [Theseus Navigator Demo web app](https://theseus-navigator.eche.dev/).
