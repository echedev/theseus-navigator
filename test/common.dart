import 'package:flutter/widgets.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

class TestDestinations {
  static final dummyBuilder = (context, parameters) => Container();

  static final home = GeneralDestination(
    path: '/home',
    builder: dummyBuilder,
  );
  static final about = GeneralDestination(
    path: '/settings/about',
    builder: dummyBuilder,
  );
  static final categories = GeneralDestination(
    path: '/categories/{id}',
    builder: dummyBuilder,
  );
  static final categoriesBrands = GeneralDestination(
    path: '/categories/{categoryId}/brands/{brandId}',
    builder: dummyBuilder,
  );
}