import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakket/model/orderplaced.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<OrderResponse?> placeOrder(
  OrderRequest order,
  BuildContext context,
) async {
  final url = Uri.parse('https://pakket-dev.vercel.app/api/app/order');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

      body: jsonEncode(order.toJson()),
    );
    print('...........33333.........');
    print(jsonEncode(order.toJson()));
    print('....................');
    print(jsonDecode(response.body));
    print('Item IDs: ${order.items.map((e) => e.item).toList()}');
    print('Option IDs: ${order.items.map((e) => e.option).toList()}');

    final data = jsonDecode(response.body);
    print('we get the response from the api : $data');
    if (response.statusCode == 201 && data['success'] == true) {
      final orderResponse = OrderResponse.fromJson(data['order']);
      return orderResponse;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Failed to place order')),
      );
      return null;
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
    return null;
  }
}
