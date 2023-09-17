import 'package:flutter/widgets.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

import 'index.dart';

class TestDestinations {
  static Widget dummyBuilder<T extends DestinationParameters>(
          BuildContext context, T? parameters) =>
      Container();

  static final home = Destination(
    path: '/home',
    builder: dummyBuilder,
    isHome: true,
  );
  static final homeRedirectionApplied = Destination(
    path: '/home',
    builder: dummyBuilder,
    isHome: true,
    redirections: [
      Redirection(
        destination: TestDestinations.login,
        validator: (destination) async => false,
      ),
    ],
  );
  static final about = Destination(
    path: '/settings/about',
    builder: dummyBuilder,
  );
  static final aboutRedirectionNotApplied = Destination(
    path: '/settings/about',
    builder: dummyBuilder,
    redirections: [
      Redirection(
        destination: TestDestinations.login,
        validator: (destination) async =>
            Future.delayed(const Duration(seconds: 5), () => true),
      ),
    ],
  );
  static final aboutRedirectionApplied = Destination(
    path: '/settings/about',
    builder: dummyBuilder,
    redirections: [
      Redirection(
        destination: TestDestinations.login,
        validator: (destination) async => false,
      ),
    ],
  );
  static final aboutWithDialogSettings = Destination(
    path: '/settings/about',
    builder: dummyBuilder,
    settings: const DestinationSettings.dialog(),
  );
  static final aboutWithQuietSettings = Destination(
    path: '/settings/about',
    builder: dummyBuilder,
    settings: const DestinationSettings.quiet(),
  );
  static final catalog = Destination(
    path: '/catalog',
    navigator: TestNavigators.catalog,
  );
  static final catalogTransit = Destination.transit(
    path: '/catalog',
    navigator: TestNavigators.catalog,
    builder: (context, parameters, childBuilder) {
      return Column(
        children: [
          const Text('Catalog'),
          Expanded(child: childBuilder(context)),
        ],
      );
    },
  );
  static final categories = Destination(
    path: '/categories/{id}',
    builder: dummyBuilder,
  );
  static final categoriesTyped = Destination<CategoriesParameters>(
    path: '/categories/{parentId}',
    builder: dummyBuilder,
    parser: CategoriesParser(),
    upwardDestinationBuilder: (destination) async {
      final parameters = destination.parameters;
      if (parameters == null) {
        return null;
      }
      final parent = parameters.parent;
      if (parent == null || parent.id == 1) {
        return null;
      }
      return destination.withParameters(
          CategoriesParameters(parent: categoriesDataSource[parent.id - 2]));
    },
  );
  static final categoriesBrands = Destination(
    path: '/categories/{categoryId}/brands/{brandId}',
    builder: dummyBuilder,
  );
  static final login = Destination(
    path: '/login',
    builder: dummyBuilder,
  );
  static final error = Destination(
    path: '/error',
    builder: dummyBuilder,
  );
}

class TestNavigators {
  static final catalog = NavigationController(destinations: [
    TestDestinations.categories,
    TestDestinations.categoriesBrands,
  ], tag: 'Catalog');
}
