---
layout: page
title: Bottom navigation bar
---

### REQUIREMENTS

- The app should display two sections, "Tasks" and "Settings", and allow to switch between them by a bottom navigation bar.
- The "Tasks" section should support nested navigation.
    - Initially a Task list screen is displayed in the "Tasks" section.
    - Clicking on a task in the list should open a Task details screen within the same "Tasks" section.
    - The Task details screen shoudl allow to navigate back to Task list screen.
    - When the Task details screen is opened and user switch to the "Settings" section by the bottom bar, the state of "Tasks" section should remain. Once switch back to "Tasks" section, user should still see the Task details screen and be able to return back to Task list. 
- A state of screens should be persisted while switching between sections.
    - Particulary, the scroll position on the Task list screen should persist when user switch to the "Settings" section and return back to "Tasks".

### HOW TO IMPLEMENT

### 1. Design the navigation scheme

![Navigator - Cookbook - Bottom navigation bar](https://user-images.githubusercontent.com/11990453/212497261-6fc97098-5948-4a47-91f2-f83e70d33bbc.jpg)

Key points:

- Based on the app requirements we will have two primary destinations, which correspond to the bottom navigation bar items.

- We have to explicitly define a root `NavigationController` because we want to use NavigationBar widget to switch primary destinations.

- The primary [`Destination`](https://pub.dev/documentation/theseus_navigator/latest/theseus_navigator/Destination-class.html) corresponding to the "Tasks" item of the bottom navigation bar will not display a content directly. It will keep a reference to a nested navigation controller.

- Tasks navigation controller will manage of two nested destinations. One of them will display a list of tasks, and abother will display task details.

- Task details destination should always return back to the Task list destination.

- The primary destination corresponding to the "Settings" item of the bottom navigation bar will display its content directly.

### 2. Configure the navigation scheme in the code

#### 2.1. Root navigation widget

Create [`NavigationScheme`](https://pub.dev/documentation/theseus_navigator/latest/theseus_navigator/NavigationScheme-class.html) instance with explicitly specified root [`NavigationController`](https://pub.dev/documentation/theseus_navigator/latest/theseus_navigator/NavigationController-class.html) that uses Flutter's [*NavigationBar*](https://api.flutter.dev/flutter/material/NavigationBar-class.html) as a navigation widget.

```dart
final navigationScheme = NavigationScheme(
  navigator: NavigationController(
    destinations: [
    ],
    builder: BottomNavigationBuilder.navigationBar(
      navigationBarItems: const [
        NavigationDestination(
          icon: Icon(Icons.list_rounded),
          label: 'Tasks',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz_rounded),
          label: 'Settings',
        ),
      ],
    ),
  ),
);
```

> You can adjust appearance of the NavigationBar widget by specifying [navigationBarParameters](https://pub.dev/documentation/theseus_navigator/latest/theseus_navigator/BottomNavigationBuilder/navigationBarParameters.html) of the `BottomNavigationBar.navigationBar` constructor. It contains all parameters which are supported by `NavigationBar` widget.
 
#### 2.2. Primary destiantions

Add primary destinations that corresponds to navigation bar items

```dart
final navigationScheme = NavigationScheme(
  navigator: NavigationController(
    destinations: [
      Destination.transit(
        path: '/tasks/root',
        isHome: true,
        navigator: NavigationController(
          destinations: [
          ],
        ),
      ),
      Destination(
        path: '/settings',
        builder: (context, parameters) => const SettingsScreen(),
      ),
    ],
    builder: BottomNavigationBuilder.navigationBar(
        //...
    ),
  ),
);
```
The "Tasks" item destination will not display a content directly. It does keep a reference to a nested navigation controller.

> We used [`Destination.transit`](https://pub.dev/documentation/theseus_navigator/latest/theseus_navigator/Destination/Destination.transit.html) named constructor for tasks root destination. It is a recommended way of defining nested navigation. This constructor also has a `builder` parameter with additional `child` argument, which allows to provide a wrapper widget subtree for nested content.

#### 2.3. Tasks destinations

For easier referencing tasks destinations we create them as static members of `TasksDestinations` class.

```dart
class TasksDestinations {
  static final taskList = Destination(
    path: '/tasks',
    builder: (context, parameters) => const TaskListScreen(),
  );

  static final taskDetails = Destination(
    path: '/task/{id}',
    builder: (context, parameters) => TaskDetailsScreen(taskId: parameters?.map['id']),
    upwardDestinationBuilder: (destination) => taskList,
  );
}
```
Note that we specified [`upwardDestinationBuilder`](https://pub.dev/documentation/theseus_navigator/latest/theseus_navigator/Destination/upwardDestinationBuilder.html) parameter of **taskDetails** destiantion, so it would return the **taskList** destination. This makes Task details screen to be always on top of Task list screen in the navigation stack, even if the user opened Task details screen directly, for example via a deeplink.

Then add tasks destinations to our navigation scheme in the scope of tasks navigation controller.

```dart
final navigationScheme = NavigationScheme(
  navigator: NavigationController(
    destinations: [
      Destination.transit(
        path: '/tasks/root',
        isHome: true,
        navigator: NavigationController(
          destinations: [
            TasksDestinations.taskList,
            TasksDestinations.taskDetails,
          ],
        ),
      ),
      // ...
    ],
    builder: BottomNavigationBuilder.navigationBar(
        // ...
    ),
  ),
);
```

#### 3. Setup the app router

The `NavigationScheme` provides custom [*RouterDelegate*](https://api.flutter.dev/flutter/widgets/RouterDelegate-class.html) and [*RouteInformationParser*](https://api.flutter.dev/flutter/widgets/RouteInformationParser-class.html), which you should pass to your MaterialApp widget:

```dart
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
```

#### 4. Implement Task list screen

A Task list screen will display a list of Task objects. When user click on some task, we open Task details screen for a selected task.

```dart
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'),),
      body: ListView(
        children: [...tasks.map((e) => ListTile(
          title: Text(e.name),
          subtitle: Text(e.id),
          onTap: () => navigationScheme.goTo(TasksDestinations.taskDetails
              .withParameters(DestinationParameters({'id': e.id}))),
        )).toList()],
      ),
    );
  }
}
```
- In the 'onTap' handler we call the [`goTo`](https://pub.dev/documentation/theseus_navigator/latest/theseus_navigator/NavigationScheme/goTo.html) method of our **navigationScheme** for navigating to the **taskDetails** destination.
- We are using [`withParameters`](https://pub.dev/documentation/theseus_navigator/latest/theseus_navigator/Destination/withParameters.html) method to create a copy of the template **taskDetails** destination with specific task **id**.

> [`DestinationParameters`](https://pub.dev/documentation/theseus_navigator/latest/theseus_navigator/DestinationParameters-class.html) is a base class that provides parameters as a *Map<String, String>* collection. It can be used for any destination, which is not specialized with certain type of parameters.

#### 5. Implement Task details screen

A Task details screen just displays a name and id of provided task. The content is wrapped in a *Scaffold* widget, so the back arrow button will appear in the app bar to be able to return back to the Task list screen.

```dart
class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  final String? taskId;

  @override
  Widget build(BuildContext context) {
    final task = tasks.firstWhereOrNull((element) => element.id == taskId,);
    return Scaffold(
      appBar: AppBar(title: const Text('Task details'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(task?.name ?? ''),
            Text(task?.id ?? ''),
          ],
        ),
      ),
    );
  }
}
```

#### 6. Implement Settings screen

A Settings screen is pretty simple. It will be displayed when user select "Settings" item of the bottom navigation bar.

```dart
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'),),
      body: Center(child: Text(runtimeType.toString())),
    );
  }
}
```

### RESULT

We've implemented a nested navigation in the app, where primary destinations are switched by bottom navigation bar widget, and nested destiantions are pushed in the stack.

[Bottom navigation bar demo](https://user-images.githubusercontent.com/11990453/212546104-39f7a878-c78c-4606-a95c-087008f196e2.mp4)

The following features are supported:
- The state of screens, particulary the scroll position in the Task list screen, persists while switching bottom navigation bar items.
- The State of the nested navigation, particulary the stack of screens in the "Tasks" section also persists.
- When open a Task details screen by a deeplink, the navigation state of "Tasks" section is restored automatically, meaning the Task list screen is added to the stack below the Task details screen.

You can find a full source code of this example [here](../../example/lib/cookbook/bottom_navigation_bar_01.dart).
