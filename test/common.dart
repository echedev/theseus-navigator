import 'package:flutter/widgets.dart';

import 'package:theseus_navigator/theseus_navigator.dart';

class TestDestinations {
  static Widget dummyBuilder<T extends DestinationParameters>(
          BuildContext context, T? parameters) =>
      Container();

  static final home = DestinationLight(
    path: '/home',
    builder: dummyBuilder,
  );
  static final about = DestinationLight(
    path: '/settings/about',
    builder: dummyBuilder,
  );
  static final categories = DestinationLight(
    path: '/catalog/{id}',
    builder: dummyBuilder,
  );
  static final categoriesBrands = DestinationLight(
    path: '/catalog/{categoryId}/brands/{brandId}',
    builder: dummyBuilder,
  );
}
