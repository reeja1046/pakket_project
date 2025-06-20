import 'package:pakket/controller/order.dart';
import 'package:pakket/model/order.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<OrderDetail> fetchOrderDetail(String orderId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final url = 'https://pakket-dev.vercel.app/api/app/order/$orderId';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return OrderDetail.fromJson(data['order']);
  } else {
    throw Exception('Failed to load order');
  }
}

Future<List<Order>> fetchOrders() async {
  print('///////////');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final response = await http.get(
    Uri.parse('https://pakket-dev.vercel.app/api/app/order'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  print('88888888888888888888888888888888888888888888888');
  print(response.body);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List orders = data['orders'];
    return orders.map((json) => Order.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load orders');
  }
}
