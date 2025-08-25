import 'package:flutter/material.dart';
import 'package:pakket/controller/token_checking_helper.dart';
import 'package:pakket/model/cartadding.dart';
import 'package:pakket/model/cartfetching.dart';
import 'package:pakket/model/product.dart';

/// Add to Cart
Future<CartResponseModel?> addToCart({
  required String itemId,
  required String optionId,
  required int quantity,
}) async {
  final data = await postRequest(
    'https://pakket-dev.vercel.app/api/app/cart',
    {
      'item': itemId,
      'option': optionId,
      'quantity': quantity,
    },
  );

  if (data == null) return null; // token expired handled globally

  return CartResponseModel.fromJson(data);
}

/// Get Cart
Future<List<CartItemModelFetching>> getCart() async {
  final data = await getRequest('https://pakket-dev.vercel.app/api/app/cart');

  if (data == null) return [];

  final List items = data['cart'];
  return items.map((e) => CartItemModelFetching.fromJson(e)).toList();
}

/// Enrich Cart Items with Product Details
Future<void> enrichCartItems(List<CartItemModel> items) async {
  for (final item in items) {
    final data = await getRequest(
        'https://pakket-dev.vercel.app/api/app/product/${item.itemId}');
    if (data == null) return; // token expired handled globally

    final product = ProductDetail.fromJson(data['product']);

    final matchedOption = product.options.firstWhere(
      (opt) => opt.id == item.optionId,
      orElse: () => product.options.first,
    );

    item.title = product.title;
    item.imageUrl = product.thumbnail;
    item.unit = matchedOption.unit;
    item.offerPrice = matchedOption.offerPrice;
  }
}

/// Delete Cart Item
Future<bool> deleteCartItem(String itemId, BuildContext context) async {
  final data = await deleteRequest(
      'https://pakket-dev.vercel.app/api/app/cart?itemId=$itemId');

  if (data == null) return false;

  if (data['success'] == true) {
    return true;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Failed to delete item')),
    );
    return false;
  }
}

/// Update Cart Item Quantity
Future<bool> updateCartItemQuantity(
    String itemId, String operation, BuildContext context) async {
  final data = await patchRequest(
    'https://pakket-dev.vercel.app/api/app/cart',
    {
      'itemId': itemId,
      'operation': operation, // 'inc' or 'dec'
    },
  );

  if (data == null) return false;

  if (data['success'] == true) {
    return true;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? 'Failed to update cart item')),
    );
    return false;
  }
}
