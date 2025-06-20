import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakket/model/trending.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Product>> fetchTrendingProducts() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final response = await http.get(
    Uri.parse('https://pakket-dev.vercel.app/api/app/product/trending?limit=1'),
    headers: {
      'Authorization': 'Bearer $token', // 👈 Using the saved token here
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List result = data['result'];
    return result.map((item) => Product.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load trending products: ${response.body}');
  }
}

