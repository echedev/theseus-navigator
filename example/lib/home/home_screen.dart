// ignore_for_file: public_member_api_docs

import 'package:example/home/home_navigator.dart';
import 'package:flutter/material.dart';
import 'package:theseus_navigator/theseus_navigator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../catalog/index.dart';
import '../navigation.dart';
import '../widgets/info_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
    this.title,
    this.next = false,
  }) : super(key: key);

  final String? title;

  final bool next;

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async {
        return false;
      },
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(title ?? 'Home'),
          ),
          body: ListView(
            children: [
              InfoItem(
                title: 'Theseus Navigator',
                description: 'A demo app of Theseus Navigator package.\nversion 0.8.3',
                isAccentStyle: true,
                isCentered: true,
                child: ElevatedButton(
                    onPressed: _openPubDev,
                    child: const Text('Open on PUB.DEV')),
              ),
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
                      navigationScheme
                          .goTo(CatalogDestinations.categories.copyWith(
                        parameters: CategoriesDestinationParameters(
                            parentCategory:
                                await CategoryRepository().getCategory('3')),
                        settings: CatalogDestinations.categories.settings
                            .copyWith(reset: true),
                      ));
                    },
                    child: const Text('Category 3')),
              ),
              InfoItem(
                title: 'Dialog',
                description: '''Display a modal dialog''',
                onTap: () {
                  navigationScheme.goTo(HomeDestinations.dialog.withParameters(
                      DestinationParameters(
                          {'from': navigationScheme.currentDestination.path})));
                },
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
                      navigationScheme.goTo(Destination(
                        path: '/nonexistent',
                        builder: (context, parameters) => const HomeScreen(),
                      ));
                    },
                    child: const Text('Nonexistent screen')),
              ),
              if (next)
                InfoItem(
                  title: 'Navigate next screen',
                  description:
                      '''Opens another screen in the same bottom navigation tab. New screen will be added to the local navigation stack.''',
                  child: ElevatedButton(
                      onPressed: () async {
                        navigationScheme.goTo(HomeDestinations.home2);
                      },
                      child: const Text('Home 2')),
                ),
              const SizedBox(
                height: 20.0,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPubDev() async {
    if (!await launchUrl(
        Uri.parse('https://pub.dev/packages/theseus_navigator'))) {
      throw 'Could not launch url';
    }
  }
}
