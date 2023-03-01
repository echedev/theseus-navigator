import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

void main() => runApp(const App());

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
      Destination(
        path: '/settings',
        builder: (context, parameters) => const SettingsScreen(),
      ),
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

class TasksDestinations {
  static final taskList = Destination(
    path: '/tasks',
    builder: (context, parameters) => const TaskListScreen(),
  );

  static final taskDetails = Destination(
    path: '/task/{id}',
    builder: (context, parameters) => TaskDetailsScreen(taskId: parameters?.map['id']),
    upwardDestinationBuilder: (destination) async => taskList,
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

const tasks = <Task>[
  Task(id: '1', name: 'Task 1'),
  Task(id: '2', name: 'Task 2'),
  Task(id: '3', name: 'Task 3'),
  Task(id: '4', name: 'Task 4'),
  Task(id: '5', name: 'Task 5'),
  Task(id: '6', name: 'Task 6'),
  Task(id: '7', name: 'Task 7'),
  Task(id: '8', name: 'Task 8'),
  Task(id: '9', name: 'Task 9'),
  Task(id: '10', name: 'Task 10'),
];

class Task {
  const Task({
    required this.id,
    required this.name,
  });

  final String id;

  final String name;
}