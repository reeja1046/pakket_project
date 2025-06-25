class CartItemModelFetching {
  final String itemId;
  final String productId;
  final String title;
  final String imageUrl;
  final String unit;
  final double basePrice;
  final double offerPrice;
  final bool inStock;
  int quantity;
  final String optionId;

  CartItemModelFetching({
    required this.itemId,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.unit,
    required this.basePrice,
    required this.offerPrice,
    required this.inStock,
    required this.quantity,
    required this.optionId,
  });

  factory CartItemModelFetching.fromJson(Map<String, dynamic> json) {
    return CartItemModelFetching(
      itemId: json['itemId'],
      productId: json['productId'],
      title: json['title'],
      imageUrl: json['thumbnail']['url'],
      unit: json['option']['unit'],
      basePrice: (json['option']['basePrice'] as num).toDouble(),
      offerPrice: (json['option']['offerPrice'] as num).toDouble(),
      inStock: json['option']['inStock'],
      quantity: json['quantity'],
      optionId: json['option']['_id'],
    );
  }
}
