// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'category.dart';
import 'catalog_navigator.dart';
import 'category_repository.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Category>>(
            future:
                categoryRepository.getCategories(parent: widget.parentCategory),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: [
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
                              child: Card(
                                child: Container(
                                  height: 100.0,
                                  alignment: Alignment.center,
                                  child: Text(category.name),
                                ),
                              ),
                            ))
                        .toList(),
                  ],
                );
              }
              return Container();
            }),
      ),
    );
  }
}
