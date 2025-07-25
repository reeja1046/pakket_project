import 'package:pakket/controller/token_checking_helper.dart';
import 'package:pakket/model/order.dart';
import 'package:pakket/model/orderfetch.dart';

/// Fetch order details
Future<OrderDetail?> fetchOrderDetail(String orderId) async {
  final data = await getRequest(
    'https://pakket-dev.vercel.app/api/app/order/$orderId',
  );

  if (data == null) return null; // token expired handled globally

  return OrderDetail.fromJson(data['order']);
}

/// Fetch all orders
Future<List<Order>> fetchOrders() async {
  final data = await getRequest('https://pakket-dev.vercel.app/api/app/order');

  if (data == null) return []; // token expired handled globally

  final List orders = data['orders'];
  return orders.map((json) => Order.fromJson(json)).toList();
}
