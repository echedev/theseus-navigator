// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'category.dart';
import 'catalog_navigator.dart';
import 'category_repository.dart';
import '../widgets/info_item.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({
    Key? key,
    this.parentCategory,
  }) : super(key: key);

  final Category? parentCategory;

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final CategoryRepository categoryRepository = CategoryRepository();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentCategory?.name ?? 'Catalog'),
      ),
      body: FutureBuilder<List<Category>>(
          future:
              categoryRepository.getCategories(parent: widget.parentCategory),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: [
                  const InfoItem(
                    title: 'Nested navigation',
                    description:
                        '''The Catalog screen is managed by its own nested TheseusNavigator. It keeps the navigation state in the catalog, while you are switching to other primary destinations using bottom navigation bar.''',
                    isDarkStyle: true,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ...snapshot.data!
                      .map((category) => InkWell(
                            onTap: () {
                              catalogNavigator.goTo(CatalogDestinations
                                  .categories
                                  .copyWithParameters(
                                      CategoriesDestinationParameters(
                                parentCategory: category,
                              )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                child: Container(
                                  height: 100.0,
                                  alignment: Alignment.center,
                                  child: Text(category.name),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ],
              );
            }
            return Container();
          }),
    );
  }
}
