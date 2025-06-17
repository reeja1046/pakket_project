import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/allcategory.dart';

Future<List<Category>> fetchCategories() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  print(token);
  final response = await http.get(
    Uri.parse('https://pakket-dev.vercel.app/api/app/category'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  // print(response.body);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List result = data['categories'];
    print(result);
    return result.map((item) => Category.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load categories: ${response.body}');
  }
}



Future<List<CategoryProduct>> fetchProductsByCategory(String categoryId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final response = await http.get(
    Uri.parse(
        'https://pakket-dev.vercel.app/api/app/product?category=$categoryId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    if (decoded['success'] == true && decoded['products'] is List) {
      final List<dynamic> data = decoded['products'];
      return data.map((e) => CategoryProduct.fromJson(e)).toList();
    } else {
      throw Exception('API returned no products or malformed response');
    }
  } else {
    throw Exception('Failed to load category products');
  }
}
