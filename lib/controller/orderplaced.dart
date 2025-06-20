import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakket/model/orderplaced.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> placeOrder(OrderRequest order, BuildContext context) async {
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

    final data = jsonDecode(response.body);
    print(data);
    print(
      '************************------------***********--------************-------------***********',
    );
    if (response.statusCode == 200 && data['success'] == true) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Order Placed'),
          content: Text('Order ID: ${data['order']['orderId']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      throw Exception(data['message'] ?? 'Failed to place order');
    }
  } catch (e) {
    // Show error
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}
