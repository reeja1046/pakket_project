import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:pakket/model/allcategory.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<CategoryProduct>> fetchRandomProducts(int maxCount) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final response = await http.get(
    Uri.parse('https://pakket-dev.vercel.app/api/app/product'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    if (decoded['success'] == true && decoded['products'] is List) {
      final List<dynamic> data = decoded['products'];
      List<CategoryProduct> allProducts = data
          .map((e) => CategoryProduct.fromJson(e))
          .toList();

      allProducts.shuffle(Random());
      return allProducts.take(min(maxCount, allProducts.length)).toList();
    } else {
      throw Exception('API returned no products or malformed response');
    }
  } else {
    throw Exception('Failed to load products');
  }
}
