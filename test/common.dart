import 'package:flutter/widgets.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

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
  static final catalog = Destination(
    path: '/catalog',
    navigator: TestNavigators.catalog,
  );
  static final categories = Destination(
    path: '/categories/{id}',
    builder: dummyBuilder,
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