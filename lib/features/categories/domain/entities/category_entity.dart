class CategoryEntity {
  final String id;
  final String name;
  final String? description;
  final int productCount;

  CategoryEntity({
    required this.id,
    required this.name,
    this.description,
    required this.productCount,
  });

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'] ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      description: json['description'],
      productCount: json['_count']?['products'] ?? 0,
    );
  }
}
