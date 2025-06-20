class CartResponseModel {
  final bool success;
  final String message;
  final CartModel cart;

  CartResponseModel({
    required this.success,
    required this.message,
    required this.cart,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      success: json['success'],
      message: json['message'],
      cart: CartModel.fromJson(json['cart']),
    );
  }
}

class CartModel {
  final String id;
  final String user;
  final String createdAt;
  final List<CartItemModel> items;

  CartModel({
    required this.id,
    required this.user,
    required this.createdAt,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['_id'],
      user: json['user'],
      createdAt: json['createdAt'],
      items: (json['items'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList(),
    );
  }
}

class CartItemModel {
  final String itemId;
  final String productId;
  String title;
  String imageUrl;
  String unit;
  final double basePrice;
  double offerPrice;
  final bool inStock;
  final int quantity;
  final String optionId;

  CartItemModel({
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

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      optionId: json['option']['_id'],
      itemId: json['itemId'],
      productId: json['productId'],
      title: json['title'],
      imageUrl: json['thumbnail']['url'],
      unit: json['option']['unit'],
      basePrice: (json['option']['basePrice'] as num).toDouble(),
      offerPrice: (json['option']['offerPrice'] as num).toDouble(),
      inStock: json['option']['inStock'],
      quantity: json['quantity'],
    );
  }
}
