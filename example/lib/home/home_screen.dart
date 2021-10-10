import 'package:flutter/material.dart';

import '../catalog/index.dart';
import '../navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Home'),
          ElevatedButton(
              onPressed: () async {
                navigationScheme.goTo(CatalogDestinations.categories.copyWith(
                    parameters: CategoriesDestinationParameters(
                        parentCategory:
                            await CategoryRepository().getCategory('3')),
                    configuration: CatalogDestinations.categories.configuration
                        .copyWith(reset: true)));
              },
              child: Text('Category 3')),
        ],
      ),
    );
  }
}