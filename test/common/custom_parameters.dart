import 'package:theseus_navigator/theseus_navigator.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
  });

  final int id;

  final String name;
}

const categoriesDataSource = <Category>[
  Category(id: 1, name: 'Category 1'),
  Category(id: 2, name: 'Category 2'),
  Category(id: 3, name: 'Category 3'),
];

class CategoriesParameters extends DestinationParameters {
  CategoriesParameters({
    this.parent,
  });

  final Category? parent;
}

class CategoriesParser extends DestinationParser<CategoriesParameters> {
  @override
  Future<CategoriesParameters> parametersFromMap(
      Map<String, String> map) async {
    Category? parentCategory;
    if (map.containsKey('parentId')) {
      parentCategory = categoriesDataSource
          .firstWhere((element) => element.id == int.tryParse(map['parentId'] ?? ''));
    }
    return CategoriesParameters(parent: parentCategory);
  }

  @override
  Map<String, String> parametersToMap(CategoriesParameters parameters) {
    final result = <String, String>{};
    if (parameters.parent != null) {
      result['parentId'] = parameters.parent!.id.toString();
    }
    return result;
  }
}
