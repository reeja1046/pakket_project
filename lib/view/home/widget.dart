import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakket/controller/product.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/allcategory.dart';
import 'package:pakket/model/trending.dart';
import 'package:pakket/view/product/productdetails.dart';
import 'package:pakket/view/widget/modal.dart';

Widget buildHeader(
  BuildContext context,
  RxString locationStatus,
  String currentAddress1,
  String currentAddress2,
) {
  final height = MediaQuery.of(context).size.height;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: height * 0.02),
      Row(
        children: [
          // Centered logo
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/pakket-horizontal.png',
                height: height * 0.06,
              ),
            ),
          ),

          // Profile icon aligned to right
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/profile'),
            child: Image.asset('assets/home/profileicon.png'),
          ),
        ],
      ),

      const SizedBox(height: 10),
      const Text(
        'Your Location',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),

      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (locationStatus == 'fetching' ||
                  locationStatus == 'error') ...[
                const Text(
                  'Fetching location...',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ] else ...[
                Text(
                  currentAddress1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  currentAddress2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 5),
          Image.asset('assets/home/location.png', color: Colors.black),
        ],
      ),

      const SizedBox(height: 10),
    ],
  );
}

Widget buildCategoryHeader(
  BuildContext context,
  String title,
  String title2,
  VoidCallback onSeeAllPressed,
) {
  final size = MediaQuery.of(context).size;
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  final baseSize = isPortrait ? size.width : size.height; // shorter side

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: baseSize * 0.045, // scales nicely for both orientations
          fontWeight: FontWeight.bold,
        ),
      ),
      GestureDetector(
        onTap: onSeeAllPressed,
        child: Text(
          title2,
          style: TextStyle(
            fontSize: baseSize * 0.035,
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

Widget buildProductGrid(List<CategoryProduct> products) {
  final displayProducts = products.take(8).toList();

  return LayoutBuilder(
    builder: (context, constraints) {
      final isPortrait =
          MediaQuery.of(context).orientation == Orientation.portrait;

      // Dynamic columns
      final crossAxisCount = isPortrait ? 4 : 6; // more columns in landscape

      final screenWidth = constraints.maxWidth;

      // Width per item
      final itemWidth = screenWidth / crossAxisCount;

      // Adjust height proportionally (slightly shorter in landscape)
      final itemHeight = isPortrait ? itemWidth * 1.8 : itemWidth * 1.6;
      final aspectRatio = itemWidth / itemHeight;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            final product = displayProducts[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetails(productId: product.productId),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: itemWidth, // square image
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Widget showTrendingProduct(Future<List<Product>> trendingProducts) {
  return FutureBuilder<List<Product>>(
    future: trendingProducts,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No trending products available'));
      }

      final products = snapshot.data!;

      return OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          final size = MediaQuery.of(context).size;
          final shortestSide = size.shortestSide;
          final screenWidth = size.width;

          /// Make card width smaller in landscape
          final cardWidth = isPortrait ? screenWidth * 0.4 : screenWidth * 0.22;

          /// Image height proportional to card width
          final imageHeight = isPortrait ? cardWidth * 0.6 : cardWidth * 0.4;

          /// Keep font size same as before (no change)
          final fontSize = shortestSide * 0.035;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, CustomColors.baseContainer],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: buildCategoryHeader(
                    context,
                    'Trending Products',
                    '',
                    () {},
                  ),
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: List.generate(products.length, (index) {
                        final product = products[index];
                        final option = product.options.first;

                        return GestureDetector(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetails(productId: product.id),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              right: isPortrait
                                  ? screenWidth * 0.025
                                  : screenWidth * 0.015,
                            ),
                            width: cardWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.all(cardWidth * 0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    color: CustomColors.baseContainer,
                                    height: imageHeight,
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Image.network(
                                        product.thumbnail,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: shortestSide * 0.02),
                                Text(
                                  product.title,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: shortestSide * 0.01),
                                Text(
                                  option.unit,
                                  style: TextStyle(
                                    fontSize: fontSize * 0.8,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rs.${option.offerPrice.floor()}',
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                      width: isPortrait ? 80 : 65,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor:
                                              CustomColors.baseColor,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final productDetail =
                                              await fetchProductDetail(
                                                product.id,
                                              );
                                          showProductOptionBottomSheet(
                                            context: context,
                                            product: productDetail!,
                                          );
                                        },
                                        child: const Text(
                                          'Add',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      );
    },
  );
}
