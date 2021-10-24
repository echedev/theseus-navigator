// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../catalog/index.dart';
import '../navigation.dart';
import '../widgets/info_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView(
        children: [
          InfoItem(
            title: 'Deep link',
            description:
                '''Opens screen for specific category, deeply in the categories hierarchy. The bottom navigation bar will be switched to the "Catalog" tab, and the parent category screens will be added to the navigation stack''',
            child: ElevatedButton(
                onPressed: () async {
                  navigationScheme.goTo(CatalogDestinations.categories.copyWith(
                      parameters: CategoriesDestinationParameters(
                          parentCategory:
                              await CategoryRepository().getCategory('3')),
                      configuration: CatalogDestinations
                          .categories.configuration
                          .copyWith(reset: true)));
                },
                child: const Text('Category 3')),
          ),
          InfoItem(
            title: 'Custom transition animations',
            description:
                '''Opens new screen with a custom transition animations''',
            onTap: () {
              navigationScheme.goTo(PrimaryDestinations.customTransition);
            },
          ),
        ],
      ),
    );
  }
}
