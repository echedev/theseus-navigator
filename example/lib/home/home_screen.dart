// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../catalog/index.dart';
import '../navigation.dart';

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
          Padding(
            padding: const EdgeInsets.only(top:20.0, left: 16.0, right: 16.0),
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Deep link',
                      style: GoogleFonts.robotoMono(
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text('''Opens screen for specific category, deeply in the categories hierarchy. The bottom navigation bar will be switched to the "Categories" tab, and the parent category screens will be added to the navigation stack'''),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
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
                  ],
                ),
              ),
            )
          ),
          Padding(
              padding: const EdgeInsets.only(top:20.0, left: 16.0, right: 16.0),
              child: Card(
                child: InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Custom transition animations',
                          style: GoogleFonts.robotoMono(
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Text('''Opens new screen with a custom transition animations'''),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    navigationScheme.goTo(PrimaryDestinations.customTransition);
                  },
                ),
              )
          ),
        ],
      ),
    );
  }
}
