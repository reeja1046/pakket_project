class ProductOption {
  final String id; // <-- Required for cart
  final String unit;
  final double basePrice;
  final double offerPrice;

  ProductOption({
    required this.id,
    required this.unit,
    required this.basePrice,
    required this.offerPrice,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['_id'], // <-- Fix: Parse _id from JSON
      unit: json['unit'],
      basePrice: (json['basePrice'] as num).toDouble(),
      offerPrice: (json['offerPrice'] as num).toDouble(),
    );
  }
}

class ProductDetail {
  final String id; // <-- Required for cart
  final String title;
  final String description;
  final String thumbnail;
  final List<String> images;
  final List<ProductOption> options;

  ProductDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.images,
    required this.options,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['_id'], // <-- Fix: Parse _id from JSON
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      images: List<String>.from(json['images']),
      options: (json['options'] as List)
          .map((e) => ProductOption.fromJson(e))
          .toList(),
    );
  }
}
