import 'dart:math';
import 'package:pakket/controller/token_checking_helper.dart';
import 'package:pakket/model/allcategory.dart';

/// Fetch random products (shuffled, limited by maxCount)
Future<List<CategoryProduct>> fetchRandomProducts(int maxCount) async {
  final data = await getRequest('https://pakket-dev.vercel.app/api/app/product');

  if (data == null) return []; // token expired handled globally

  if (data['success'] == true && data['products'] is List) {
    final List<dynamic> products = data['products'];
    List<CategoryProduct> allProducts =
        products.map((e) => CategoryProduct.fromJson(e)).toList();

    allProducts.shuffle(Random());
    return allProducts.take(min(maxCount, allProducts.length)).toList();
  } else {
    throw Exception('API returned no products or malformed response');
  }
}

/// Fetch all products
Future<List<CategoryProduct>> fetchAllProducts() async {
  final data = await getRequest('https://pakket-dev.vercel.app/api/app/product');

  if (data == null) return [];

  if (data['success'] == true && data['products'] is List) {
    final List<dynamic> products = data['products'];
    return products.map((e) => CategoryProduct.fromJson(e)).toList();
  } else {
    throw Exception('API returned no products or malformed response');
  }
}
