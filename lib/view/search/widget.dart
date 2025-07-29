import 'package:flutter/material.dart';
import 'package:pakket/controller/product.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/product/productdetails.dart';
import 'package:pakket/view/widget/modal.dart';

Widget buildProductCard(dynamic product, BuildContext context) {
  final thumbnail = product['thumbnail'] ?? '';
  final title = product['title'] ?? 'No title';
  final options = product['options'] ?? [];
  final option = options.isNotEmpty ? options[0] : null;
  final productId = product['productId'];

  // Detect orientation and screen size
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  final screenWidth = MediaQuery.of(context).size.width;
  final shortestSide = MediaQuery.of(context).size.shortestSide;

  // Dynamic sizing
  final imageHeight = isPortrait ? shortestSide * 0.22 : shortestSide * 0.18;
  final titleFontSize = isPortrait ? shortestSide * 0.04 : shortestSide * 0.035;
  final priceFontSize = isPortrait ? shortestSide * 0.035 : shortestSide * 0.03;
  final buttonHeight = isPortrait ? shortestSide * 0.075 : shortestSide * 0.08;
  final buttonWidth = isPortrait ? screenWidth * 0.3 : screenWidth * 0.2;

  return GestureDetector(
    onTap: () async {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetails(productId: productId),
          ),
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
          // Product Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: CustomColors.baseContainer,
            ),
            padding: const EdgeInsets.all(10),
            child: Image.network(
              thumbnail,
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
            ),
          ),

          // Title
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Divider(indent: 10, endIndent: 10),

          // Unit and Price Row
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  option?['unit'] ?? '',
                  style: TextStyle(fontSize: priceFontSize),
                ),
                const VerticalDivider(),
                Text(
                  'Rs. ${option?['basePrice'] ?? ''}',
                  style: TextStyle(
                    fontSize: priceFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // Add Button
          SizedBox(
            height: buttonHeight,
            width: buttonWidth,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: CustomColors.baseColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () async {
                final productDetail = await fetchProductDetail(productId);
                showProductOptionBottomSheet(
                  context: context,
                  product: productDetail!,
                );
              },
              child: Text(
                options.length == 1 ? 'Add' : '${options.length} options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: priceFontSize,
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
