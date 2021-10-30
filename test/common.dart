import 'package:flutter/widgets.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

class TestDestinations {
  static Widget dummyBuilder<T extends DestinationParameters>(
          BuildContext context, T? parameters) =>
      Container();

  static final home = DestinationLight(
    path: '/home',
    builder: dummyBuilder,
    isHome: true,
  );
  static final about = DestinationLight(
    path: '/settings/about',
    builder: dummyBuilder,
  );
  static final catalog = DestinationLight(
    path: '/catalog',
    navigator: TestNavigators.catalog,
  );
  static final categories = DestinationLight(
    path: '/categories/{id}',
    builder: dummyBuilder,
  );
  static final categoriesBrands = DestinationLight(
    path: '/categories/{categoryId}/brands/{brandId}',
    builder: dummyBuilder,
  );
  static final login = DestinationLight(
    path: '/login',
    builder: dummyBuilder,
  );
  static final error = DestinationLight(
    path: '/error',
    builder: dummyBuilder,
  );
}

class TestNavigators {
  static final catalog = TheseusNavigator(
    destinations: [
      TestDestinations.categories,
      TestDestinations.categoriesBrands,
    ],
  );
}