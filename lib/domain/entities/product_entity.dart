class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final int discountPercent;
  final int stock;
  final String categoryId;
  final String categoryName;
  final List<ProductImage> images;
  final double finalPrice;
  final double savings;
  final String? discountBadge;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.discountPercent,
    required this.stock,
    required this.categoryId,
    required this.categoryName,
    required this.images,
    required this.finalPrice,
    required this.savings,
    this.discountBadge,
  });

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final double price = parseDouble(json['price']);
    final double? discountedPrice = json['discountedPrice'] != null
        ? parseDouble(json['discountedPrice'])
        : null;

    final double finalPrice = json['finalPrice'] != null
        ? parseDouble(json['finalPrice'])
        : (discountedPrice ?? price);

    final double savings = json['savings'] != null
        ? parseDouble(json['savings'])
        : (price - finalPrice);

    return ProductEntity(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: price,
      discountedPrice: discountedPrice,
      discountPercent: (price > 0 && finalPrice < price) 
          ? ((price - finalPrice) / price * 100).round() 
          : (json['discountPercent'] ?? 0),
      stock: json['stock'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      categoryName: json['category']?['name'] ?? 'Uncategorized',
      images: (json['images'] as List? ?? [])
          .map((img) => ProductImage.fromJson(img))
          .toList(),
      finalPrice: finalPrice,
      savings: savings,
      discountBadge: json['discountBadge'],
    );
  }
}

class ProductImage {
  final String id;
  final String url;
  final String? altText;

  ProductImage({required this.id, required this.url, this.altText});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      url: json['url'],
      altText: json['altText'],
    );
  }
}
