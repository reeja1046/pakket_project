class Category {
  final String id;
  final String name;
  final String iconUrl;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      iconUrl: json['icon']['url'],
      imageUrl: json['image']['url'],
    );
  }
}
class CategoryProduct {
  final String productId;
  final String title;
  final String thumbnail;
  final List<ProductOption> options;

  CategoryProduct({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.options,
  });

  factory CategoryProduct.fromJson(Map<String, dynamic> json) {
    return CategoryProduct(
      productId: json['productId'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      options: (json['options'] as List)
          .map((opt) => ProductOption.fromJson(opt))
          .toList(),
    );
  }
}

class ProductOption {
  final String unit;
  final double basePrice;
  final double offerPrice;
  final bool inStock;
  final String id;

  ProductOption({
    required this.unit,
    required this.basePrice,
    required this.offerPrice,
    required this.inStock,
    required this.id,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      unit: json['unit'] ?? '',
      basePrice: (json['basePrice'] as num).toDouble(),
      offerPrice: (json['offerPrice'] as num).toDouble(),
      inStock: json['inStock'] ?? false,
      id: json['_id'] ?? '',
    );
  }
}
