import 'package:flutter/widgets.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

class TestDestinations {
  static final dummyBuilder = (context, parameters) => Container();

  static final home = DestinationLight(
    path: '/home',
    builder: dummyBuilder,
  );
  static final about = DestinationLight(
    path: '/settings/about',
    builder: dummyBuilder,
  );
  static final categories = DestinationLight(
    path: '/categories/{id}',
    builder: dummyBuilder,
  );
  static final categoriesBrands = DestinationLight(
    path: '/categories/{categoryId}/brands/{brandId}',
    builder: dummyBuilder,
  );
}