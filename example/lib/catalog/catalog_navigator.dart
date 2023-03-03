// ignore_for_file: public_member_api_docs

import 'package:theseus_navigator/theseus_navigator.dart';

import 'category.dart';
import 'category_list_screen.dart';
import 'category_repository.dart';

final catalogNavigator = NavigationController(
  destinations: [
    CatalogDestinations.categories,
  ],
  tag: 'Catalog',
);

class CatalogDestinations {
  static final categories = Destination<CategoriesDestinationParameters>(
    path: '/categories',
    builder: (context, parameters) =>
        CategoryListScreen(parentCategory: parameters?.parentCategory),
    parser:
        CategoriesDestinationParser(categoryRepository: CategoryRepository()),
    upwardDestinationBuilder: (destination) async =>
        destination.parameters?.parentCategory == null
            ? null
            : destination.withParameters(CategoriesDestinationParameters(
                parentCategory:
                    destination.parameters?.parentCategory!.parent)),
  );
}

class CategoriesDestinationParameters extends DestinationParameters {
  CategoriesDestinationParameters({
    this.parentCategory,
  });

  final Category? parentCategory;
}

class CategoriesDestinationParser
    extends DestinationParser<CategoriesDestinationParameters> {
  CategoriesDestinationParser({required this.categoryRepository});

  final CategoryRepository categoryRepository;

  @override
  Future<CategoriesDestinationParameters> parametersFromMap(
      Map<String, String> map) async {
    final parentCategoryId = map['parentCategoryId'];
    if (parentCategoryId == null) {
      return CategoriesDestinationParameters();
    } else {
      final category = await categoryRepository.getCategory(parentCategoryId);
      if (category != null) {
        return CategoriesDestinationParameters(
          parentCategory: category,
        );
      } else {
        throw UnknownDestinationException();
      }
    }
  }

  @override
  Map<String, String> parametersToMap(CategoriesDestinationParameters parameters) {
    final result = <String, String>{};
    if (parameters.parentCategory != null) {
      result['parentCategoryId'] = parameters.parentCategory!.id;
    }
    return result;
  }
}
