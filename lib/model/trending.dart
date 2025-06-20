class TrendingProduct {
  final String unit;
  final double basePrice;
  final double offerPrice;
  final bool inStock;

  TrendingProduct({
    required this.unit,
    required this.basePrice,
    required this.offerPrice,
    required this.inStock,
  });

  factory TrendingProduct.fromJson(Map<String, dynamic> json) {
    return TrendingProduct(
      unit: json['unit'] ?? '',
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      inStock: json['inStock'] ?? false,
    );
  }
}

class Product {
  final String id;
  final String title;
  final String thumbnail;
  final List<TrendingProduct> options;

  Product({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.options,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['productId'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      options: (json['options'] as List)
          .map((opt) => TrendingProduct.fromJson(opt))
          .toList(),
    );
  }
}
