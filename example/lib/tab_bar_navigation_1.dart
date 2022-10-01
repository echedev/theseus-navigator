import 'package:flutter/material.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final _navigationScheme = NavigationScheme(
    navigator: TheseusNavigator(
      destinations: [
        Destination<DefaultDestinationParameters>(
          path: '/todo',
          isHome: true,
          builder: (context, parameters) => TaskListScreen(
              tasks: _tasks.where((element) => !element.isCompleted).toList()),
          tag: 'To do',
        ),
        Destination<DefaultDestinationParameters>(
          path: '/completed',
          builder: (context, parameters) => TaskListScreen(
              tasks: _tasks.where((element) => element.isCompleted).toList()),
          tag: 'Completed',
        ),
        Destination<DefaultDestinationParameters>(
          path: '/all',
          builder: (context, parameters) => const TaskListScreen(tasks: _tasks),
          tag: 'All',
        ),
      ],
      builder: TabsNavigationBuilder(
        tabs: [
          const Tab(child: Text('TO DO'),),
          const Tab(child: Text('COMPLETED'),),
          const Tab(child: Text('ALL'),),
        ],
        appBarParametersBuilder: (destination) => AppBarParameters(
          title: Text('Tasks - ${destination.tag}'),
        ),
        wrapInScaffold: true,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: TheseusRouterDelegate(
        navigationScheme: _navigationScheme,
      ),
      routeInformationParser: TheseusRouteInformationParser(
        navigationScheme: _navigationScheme,
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({
    Key? key,
    required this.tasks,
  }) : super(key: key);

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...tasks.map((element) => TaskListItem(task: element),).toList(),
      ],
    );
  }
}

class TaskListItem extends StatelessWidget {
  const TaskListItem({
    Key? key,
    required this.task,
  }) : super(key: key);

  final Task task;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.name),
    );
  }
}

class Task {
  const Task({
    required this.id,
    required this.name,
    this.description,
    this.isCompleted = false,
  });

  final int id;

  final String name;

  final String? description;

  final bool isCompleted;
}

const _tasks = <Task>[
  Task(id: 1, name: 'Task 1', description: 'Description of task #1'),
  Task(id: 2, name: 'Task 2', description: 'Description of task #2', isCompleted: true),
  Task(id: 3, name: 'Task 3', description: 'Description of task #3', isCompleted: true),
  Task(id: 4, name: 'Task 4', description: 'Description of task #4'),
  Task(id: 5, name: 'Task 5', description: 'Description of task #5'),
];
