import 'package:flutter/material.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

void main() => runApp(const App());

final navigationScheme = NavigationScheme(
  navigator: NavigationController(
    destinations: [
      Destination(
        path: '/todo',
        isHome: true,
        builder: (context, parameters) => TaskListView(
            tasks: tasks.where((element) => !element.isCompleted).toList()),
        tag: 'To do',
      ),
      Destination(
        path: '/completed',
        builder: (context, parameters) => TaskListView(
            tasks: tasks.where((element) => element.isCompleted).toList()),
        tag: 'Completed',
      ),
      Destination(
        path: '/all',
        builder: (context, parameters) => const TaskListView(tasks: tasks),
        tag: 'All',
      ),
    ],
    builder: TabsNavigationBuilder(
      tabs: [
        const Tab(child: Text('TO DO'),),
        const Tab(child: Text('COMPLETED'),),
        const Tab(child: Text('ALL'),),
      ],
      appBarParametersBuilder: (context, destination) => AppBarParameters(
        title: Text('Tasks - ${destination.tag}'),
      ),
    ),
  ),
);

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: TheseusRouterDelegate(
        navigationScheme: navigationScheme,
      ),
      routeInformationParser: TheseusRouteInformationParser(
        navigationScheme: navigationScheme,
      ),
    );
  }
}

class TaskListView extends StatelessWidget {
  const TaskListView({
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

const tasks = <Task>[
  Task(id: 1, name: 'Task 1', description: 'Description of task #1'),
  Task(id: 2, name: 'Task 2', description: 'Description of task #2', isCompleted: true),
  Task(id: 3, name: 'Task 3', description: 'Description of task #3', isCompleted: true),
  Task(id: 4, name: 'Task 4', description: 'Description of task #4'),
  Task(id: 5, name: 'Task 5', description: 'Description of task #5'),
];
