class Category {
  Category({
    required this.id,
    required this.name,
    this.parent,
  });

  final String id;

  final String name;

  final Category? parent;
}