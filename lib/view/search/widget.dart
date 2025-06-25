import 'package:flutter/material.dart';
import 'package:pakket/controller/product.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/product/productdetails.dart';

Widget buildProductCard(
  dynamic product,
  BuildContext context,
) {
  final thumbnail = product['thumbnail'] ?? '';
  final title = product['title'] ?? 'No title';
  final options = product['options'] ?? [];
  final option = options.isNotEmpty ? options[0] : null;
  final productId = product['productId'];

  return GestureDetector(
    onTap: () async {
    if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetails(productId:  productId)),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: CustomColors.textformfield,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: CustomColors.baseContainer,
            ),
            padding: const EdgeInsets.all(10),
            child: Image.network(
              thumbnail,
              height: 80,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Divider(indent: 10, endIndent: 10),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  option?['unit'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                const VerticalDivider(),
                Text(
                  'Rs. ${option?['basePrice'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
            width: MediaQuery.of(context).size.width * 0.3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.baseColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {},
              child: Text(
                options.length == 1 ? 'Add' : '${options.length} options',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
