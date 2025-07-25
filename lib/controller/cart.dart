import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakket/model/cartadding.dart';
import 'package:pakket/model/cartfetching.dart';
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

Future<List<CartItemModelFetching>> getCart() async {
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
      final List items = data['cart'];

      return items.map((e) => CartItemModelFetching.fromJson(e)).toList();
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

Future<bool> deleteCartItem(String itemId, BuildContext context) async {
  final url = Uri.parse(
    'https://pakket-dev.vercel.app/api/app/cart?itemId=$itemId',
  );
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Failed to delete item')),
      );
      return false;
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
    return false;
  }
}

Future<bool> updateCartItemQuantity(
  String itemId,
  String operation,
  BuildContext context,
) async {
  final url = Uri.parse('https://pakket-dev.vercel.app/api/app/cart');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  try {
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "itemId": itemId,
        "operation": operation, // 'inc' or 'dec'
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return true; // Successfully updated
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Failed to update cart item'),
        ),
      );
      return false;
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
    return false;
  }
}
