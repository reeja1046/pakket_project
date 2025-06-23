import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakket/model/cart.dart';
import 'package:pakket/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<CartResponseModel?> addToCart({
  required String itemId,
  required String optionId,
  required int quantity,
}) async {
  final url = Uri.parse('https://pakket-dev.vercel.app/api/app/cart');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({
    'item': itemId,
    'option': optionId,
    'quantity': quantity,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return CartResponseModel.fromJson(json);
    } else {
      print('Errorponse.statusCode}sponse');
      return null;
    }
  } catch (e) {
    print('Exception: $e');
    return null;
  }
}

Future<List<CartItemModel>> getCart() async {
  final url = Uri.parse('https://pakket-dev.vercel.app/api/app/cart');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List items = data['cart']; // ✅ fix here
      print('............................ssssssssssssssssssssssssssssss');
      print(data['cart']);
      print('............................ssssssssssssssssssssssssssssss');
      print(items.map((e) => CartItemModel.fromJson(e).productId));
      print('............................ssssssssssssssssssssssssssssss');
      return items.map((e) => CartItemModel.fromJson(e)).toList();
    } else {
      print('Error ${response.statusCode}: ${response.body}');
      return [];
    }
  } catch (e) {
    print('Exception: $e');
    return [];
  }
}

Future<void> enrichCartItems(List<CartItemModel> items) async {
  for (final item in items) {
    // fetch product using item.itemId (which is the productId)
    final res = await http.get(
      Uri.parse('https://pakket-dev.vercel.app/api/app/product/${item.itemId}'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print('*********----------------************************------------');
      print(data);
      print('*********----------------************************------------');
      final product = ProductDetail.fromJson(data['product']);

      final matchedOption = product.options.firstWhere(
        (opt) => opt.id == item.optionId,
        orElse: () => product.options.first,
      );

      // enrich fields
      item.title = product.title;
      item.imageUrl = product.thumbnail;
      item.unit = matchedOption.unit;
      item.offerPrice = matchedOption.offerPrice;
    }
  }
}
