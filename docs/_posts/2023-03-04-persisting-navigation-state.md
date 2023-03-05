---
layout: post
title:  "Persisting of the navigation state"
date:   2023-03-04 14:00:00 +0300
tags: navigation state
---
Persisting of the navigation state is a core feature of [Theseus Navigator](https://pub.dev/packages/theseus_navigator) package.

For example, if you have bottom navigiton bar for primary destintaions and each tab has its own nested navigation, the stack of pages of each tab persists when you switch to another tab.

>You can check this [recipe](https://echedev.github.io/theseus-navigator/cookbook/bottom-navigation-bar) of implementing bottom navigation with Theseus Navigator.

This behavior is supported on all platforms - mobile, desktop and web. 

However, there was no support of automatic restoration of the navigation state by a deeplink. Particualry, this caused confusing behaviour while navigating back and forward in a web browser history.

You still was able to implement state restoration from the deeplink manually, by using custom `upwardDestinationBuilder` function, which allows you to build custom stack of pages. But for complex navigation scheme it could be a tricky task.

Since **version 0.6.0**, Theseus Navigator supports automatic saving and restoration of the full navigation stack in the destination parameters.

The `keepStateInParameters` property, which controls this behaviour, is addded to a `NavigatorBuilder`. The parameter can take `always`, `auto` or `none` value. 

By default, the `auto` mode is set, which means that the navigation state will be persisted in the parameters only when the app is running on the web platform.

In case if you need automatic persisiting of the navigation state in destination parameters on all platforms, you should setup your navigation controller like this:
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

You can check persisting of the navigation state feature in [Theseus Navigator Demo web app](https://theseus-navigator.eche.dev/).