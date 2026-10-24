class CartEntity {
  final List<CartItemEntity> items;
  final double subtotal;
  final double totalSavings;
  final double total;
  final int itemCount;

  CartEntity({
    required this.items,
    required this.subtotal,
    required this.totalSavings,
    required this.total,
    required this.itemCount,
  });

  factory CartEntity.fromJson(Map<String, dynamic> json) {
    print('Parsing cart JSON: $json');

    List<CartItemEntity> itemsList = [];

    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => CartItemEntity.fromJson(item))
          .toList();
    }

    return CartEntity(
      items: itemsList,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      totalSavings: (json['totalSavings'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      itemCount: json['itemCount'] ?? itemsList.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'totalSavings': totalSavings,
      'total': total,
      'itemCount': itemCount,
    };
  }
}

class CartItemEntity {
  final String id;
  final int quantity;
  final CartProductEntity product;
  final double itemTotal;
  final double itemSavings;

  CartItemEntity({
    required this.id,
    required this.quantity,
    required this.product,
    required this.itemTotal,
    required this.itemSavings,
  });

  factory CartItemEntity.fromJson(Map<String, dynamic> json) {
    print('Parsing cart item: $json');

    return CartItemEntity(
      id: json['id'] ?? '',
      quantity: json['quantity'] ?? 1,
      product: CartProductEntity.fromJson(json['product'] ?? {}),
      itemTotal: (json['itemTotal'] ?? 0).toDouble(),
      itemSavings: (json['itemSavings'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'product': product.toJson(),
      'itemTotal': itemTotal,
      'itemSavings': itemSavings,
    };
  }

  String get productName => product.name;
  String get categoryName => product.categoryName ?? 'Uncategorized';
  String get productImage =>
      product.images.isNotEmpty ? product.images.first.url : '';
  double get price => product.price;
  double? get discountedPrice => product.discountedPrice;
  double get finalPrice => product.finalPrice;
}

class CartProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final int discountPercent;
  final int stock;
  final String categoryId;
  final String? categoryName;
  final List<CartProductImage> images;
  final double finalPrice;

  CartProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.discountPercent,
    required this.stock,
    required this.categoryId,
    this.categoryName,
    required this.images,
    required this.finalPrice,
  });

  factory CartProductEntity.fromJson(Map<String, dynamic> json) {
    return CartProductEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountedPrice: json['discountedPrice'] != null
          ? (json['discountedPrice'] as num).toDouble()
          : null,
      discountPercent: json['discountPercent'] ?? 0,
      stock: json['stock'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      categoryName: json['category']?['name'] ?? json['categoryName'] ?? 'Uncategorized',
      images: (json['images'] as List? ?? [])
          .map((img) => CartProductImage.fromJson(img))
          .toList(),
      finalPrice: (json['finalPrice'] ?? json['price']).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountedPrice': discountedPrice,
      'discountPercent': discountPercent,
      'stock': stock,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'images': images.map((img) => img.toJson()).toList(),
      'finalPrice': finalPrice,
    };
  }
}

class CartProductImage {
  final String id;
  final String url;
  final String? altText;

  CartProductImage({required this.id, required this.url, this.altText});

  factory CartProductImage.fromJson(Map<String, dynamic> json) {
    return CartProductImage(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      altText: json['altText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'altText': altText};
  }
}
