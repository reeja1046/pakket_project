class OrderItem {
  final String item;
  final String option;
  final int quantity;
  final double priceAtOrder;

  OrderItem({
    required this.item,
    required this.option,
    required this.quantity,
    required this.priceAtOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      "item": item,
      "option": option,
      "quantity": quantity,
      "priceAtOrder": priceAtOrder,
    };
  }
}

class OrderRequest {
  final String address;
  final List<OrderItem> items;

  OrderRequest({
    required this.address,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "items": items.map((e) => e.toJson()).toList(),
    };
  }
}
