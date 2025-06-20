class Order {
  final String id;
  final String orderId;
  final String status;

  Order({required this.id, required this.orderId, required this.status});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      orderId: json['orderId'],
      status: json['status'],
    );
  }
}


