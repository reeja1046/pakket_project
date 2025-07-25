import 'package:pakket/controller/token_checking_helper.dart';
import '../model/allcategory.dart';

/// Fetch all categories
Future<List<Category>> fetchCategories() async {
  final data = await getRequest('https://pakket-dev.vercel.app/api/app/category');

  if (data == null) return []; // token expired handled globally

  List result = data['categories'];
  return result.map((item) => Category.fromJson(item)).toList();
}

/// Fetch products by category
Future<List<CategoryProduct>> fetchProductsByCategory(String categoryId) async {
  final data = await getRequest(
      'https://pakket-dev.vercel.app/api/app/product?category=$categoryId');

  if (data == null) return []; // token expired handled globally

  if (data['success'] == true && data['products'] is List) {
    final List<dynamic> products = data['products'];
    return products.map((e) => CategoryProduct.fromJson(e)).toList();
  } else {
    throw Exception('API returned no products or malformed response');
  }
}
