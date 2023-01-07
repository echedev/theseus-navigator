Theseus Navigator is a navigation library made on top of Flutter Router and Navigator 2.0 APIs.

### Overview

In general, the navigation is a quite complex part of the app. It usually affects most of the app layers, like UI, business logic, app state as well as platform integration and could be very specific for certain projects.

From the other side, there are some navigation patterns and practices that you would like to have out of the box, without a lot of boilerplate code, which is required if you use Flutter’s navigation APIs directly.

Keeping those things in mind, a main goal of the package is to provide a navigation solution for your Flutter app that would be easy to use, but still powerful and flexible.

The package assumes that defining the navigation scheme of your app is one of the basic things that you should do when you start your project. The scheme includes all possible destinations to navigate and their relationships. Once you have designed the navigation of your app, you can start implementing it with Theseus Navigator.

![Navigation scheme](/assets/NavigationScheme.jpg)

### Table of Contents

* Navigation scheme
* Destinations
* Navigation controller
* Nested navigation
* Deeplinks
* Redirections
* Navigation UI patterns
