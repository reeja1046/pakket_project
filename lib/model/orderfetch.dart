class OrderDetail {
  final String orderId;
  final String status;
  final DateTime createdAt;
  final Address address;
  final List<OrderItem> items;
  final double totalPrice;
  final int deliveryCharge;
  final String note;

  OrderDetail({
    required this.orderId,
    required this.status,
    required this.createdAt,
    required this.address,
    required this.items,
    required this.totalPrice,
    required this.deliveryCharge,
    required this.note,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderId: json['_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      address: Address.fromJson(json['address']),
      items: List<OrderItem>.from(
        json['items'].map((x) => OrderItem.fromJson(x)),
      ),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      deliveryCharge: json['deliveryCharge'],
      note: json['note'] ?? '',
    );
  }
}

class Address {
  final String address;
  final String locality;
  final String? floor;
  final String? landmark;

  Address({
    required this.address,
    required this.locality,
    required this.floor,
    required this.landmark,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      address: json['address'],
      locality: json['locality'],
      floor: json['floor'],
      landmark: json['landmark'],
    );
  }
}

class OrderItem {
  final String title;
  final String thumbnail;
  final String unit;
  final int quantity;
  final double priceAtOrder;

  OrderItem({
    required this.title,
    required this.thumbnail,
    required this.unit,
    required this.quantity,
    required this.priceAtOrder,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      title: json['title'],
      thumbnail: json['thumbnail']['url'],
      unit: json['option']['unit'],
      quantity: json['quantity'],
      priceAtOrder: (json['priceAtOrder'] as num).toDouble(),
    );
  }
}
