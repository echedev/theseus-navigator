// ignore_for_file: public_member_api_docs

import 'package:collection/collection.dart';

import 'category.dart';

class CategoryRepository {
  CategoryRepository() {
    final category1 = Category(id: '1', name: 'Category 1');
    final category2 = Category(id: '2', name: 'Category 2');
    final category3 = Category(id: '3', name: 'Category 3', parent: category1);
    final category4 = Category(id: '4', name: 'Category 4', parent: category1);
    _categories = <Category>[
      category1,
      category2,
      category3,
      category4,
    ];
  }

  late final List<Category> _categories;

  Future<Category?> getCategory(String id) async {
    return _categories.firstWhereOrNull((category) => category.id == id);
  }

  Future<List<Category>> getCategories({Category? parent}) async {
    return _categories.where((category) => category.parent?.id == parent?.id).toList();
  }
}