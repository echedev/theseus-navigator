import 'package:example/catalog/category_repository.dart';
import 'package:theseus_navigator/theseus_navigator.dart';

import 'category.dart';
import 'category_list_screen.dart';

final catalogNavigator = TheseusNavigator(destinations: [
  CatalogDestinations.categories,
]);

class CatalogDestinations {
  static final categories = Destination<CategoriesDestinationParameters>(
    path: '/categories',
    builder: (context, parameters) =>
        CategoryListScreen(parentCategory: parameters?.parentCategory),
    parser:
        CategoriesDestinationParser(categoryRepository: CategoryRepository()),
    upwardDestinationBuilder: (destination) =>
        destination.parameters?.parentCategory == null
            ? null
            : destination.copyWithParameters(CategoriesDestinationParameters(
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
  Future<CategoriesDestinationParameters> toDestinationParameters(
      Map<String, String> map) async {
    final category =
        await categoryRepository.getCategory(map['parentCategoryId'] ?? '');
    return CategoriesDestinationParameters(
      parentCategory: category,
    );
  }

  @override
  Map<String, String> toMap(CategoriesDestinationParameters parameters) {
    final result = <String, String>{};
    if (parameters.parentCategory != null) {
      result['parentCategoryId'] = parameters.parentCategory!.id;
    }
    return result;
  }
}
