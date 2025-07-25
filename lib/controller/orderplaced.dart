import 'package:flutter/material.dart';
import 'package:pakket/controller/token_checking_helper.dart';
import 'package:pakket/model/orderplaced.dart';

Future<OrderResponse?> placeOrder(
  OrderRequest order,
  BuildContext context,
) async {
  final data = await postRequest(
    'https://pakket-dev.vercel.app/api/app/order',
    order.toJson(),
  );

  if (data == null) return null; // token expired handled globally

  if (data['success'] == true) {
    return OrderResponse.fromJson(data['order']);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Failed to place order')),
    );
    return null;
  }
}
