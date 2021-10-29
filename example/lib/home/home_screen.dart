// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

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
          const InfoItem(
            title: 'Primary destinations',
            description:
                '''This is default destination that is opened on app launch. Other primary destinations in this demo app are accessible by bottom navigation bar. You can also provide your custom navigation builder, like Drawer etc.''',
            isDarkStyle: true,
          ),
          InfoItem(
            title: 'Deep link',
            description:
                '''Opens screen for specific category, deeply in the categories hierarchy. The bottom navigation bar will be switched to the Catalog tab, and the parent category screens will be added to the navigation stack''',
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
          InfoItem(
            title: 'Error handling',
            description:
                '''When trying to navigate to nonexistent destination, user will be redirected to the error screen if the "errorDestination" is specified.''',
            child: ElevatedButton(
                onPressed: () async {
                  navigationScheme.goTo(DestinationLight(
                    path: '/nonexistent',
                    builder: (context, parameters) => const HomeScreen(),
                  ));
                },
                child: const Text('Nonexistent screen')),
          ),
          const SizedBox(
            height: 20.0,
          )
        ],
      ),
    );
  }
}
