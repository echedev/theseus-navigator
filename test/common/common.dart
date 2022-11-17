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
  static final about = Destination(
    path: '/settings/about',
    builder: dummyBuilder,
  );
  static final aboutWithRedirection = Destination(
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
  static final aboutWithInvalidRedirection = Destination(
    path: '/settings/about',
    builder: dummyBuilder,
    redirections: [
      Redirection(
        destination: TestDestinations.login,
        validator: (destination) async => false,
      ),
    ],
  );
  static final aboutWithDialogConfiguration = Destination(
    path: '/settings/about',
    builder: dummyBuilder,
    configuration: DestinationConfiguration.dialog(),
  );
  static final aboutWithQuietConfiguration = Destination(
    path: '/settings/about',
    builder: dummyBuilder,
    configuration: DestinationConfiguration.quiet(),
  );
  static final catalog = Destination(
    path: '/catalog',
    navigator: TestNavigators.catalog,
  );
  static final catalogTransit = Destination.transit(
    path: '/catalog',
    navigator: TestNavigators.catalog,
    builder: (context, parameters, child) {
      return Column(
        children: [
          const Text('Catalog'),
          Expanded(child: child),
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
    upwardDestinationBuilder: (destination) {
      return destination.parameters?.parent == null
          ? null
          : destination.withParameters(CategoriesParameters());
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
  static final catalog = NavigationController(
    destinations: [
      TestDestinations.categories,
      TestDestinations.categoriesBrands,
    ],
  );
}
