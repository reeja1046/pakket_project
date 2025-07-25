class OrderItem {
  final String item;
  final String option;
  final int quantity;
  final double priceAtOrder;
  final int deliveryCharge;

  OrderItem({
    required this.item,
    required this.option,
    required this.quantity,
    required this.priceAtOrder,
    required this.deliveryCharge,
  });

  Map<String, dynamic> toJson() {
    return {
      "item": item,
      "option": option,
      "quantity": quantity,
      "priceAtOrder": priceAtOrder,
      "deliveryCharge": deliveryCharge,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      deliveryCharge: json['deliveryCharge'],
      item: json['item'],
      option: json['option'],
      quantity: json['quantity'],
      priceAtOrder: (json['priceAtOrder'] as num).toDouble(),
    );
  }
}

class OrderRequest {
  final String address;
  final List<OrderItem> items;
  final int deliveryCharge;

  OrderRequest({required this.address, required this.items,required this.deliveryCharge});

  Map<String, dynamic> toJson() {
    return {
      "deliveryCharge" : deliveryCharge,
      "address": address,
      "items": items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderResponse {
  final String orderId;
  final String address;
  final String user;
  // final List<OrderItem> items;
  final String status;
  // final double totalPrice;
  final double deliveryCharge;
  // final String deliveryDate;
  final String userName;
  final String userPhone;

  OrderResponse({
    required this.orderId,
    required this.address,
    required this.user,
    // required this.items,
    required this.status,
    // required this.totalPrice,
    required this.deliveryCharge,
    // required this.deliveryDate,
    required this.userName,
    required this.userPhone,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: json['orderId'],
      address: json['address'],
      user: json['user'],
      // items: (json['items'] as List)
      //     .map((item) => OrderItem.fromJson(item))
      //     .toList(),
      status: json['status'],
      // totalPrice: (json['totalPrice'] as num).toDouble(),
      deliveryCharge: (json['deliveryCharge'] as num).toDouble(),
      // deliveryDate: json['deliveryDate'],
      userName: json['userName'],
      userPhone: json['userPhone'],
    );
  }
}
