import 'package:flutter/material.dart';
import 'package:pakket/controller/product.dart';
import 'package:pakket/controller/trending.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/trending.dart';
import 'package:pakket/view/product/productdetails.dart';
import 'package:pakket/view/widget/modal.dart';

class CheckoutDealsSection extends StatefulWidget {
  final VoidCallback onProductAdded;

  const CheckoutDealsSection({super.key, required this.onProductAdded});

  @override
  State<CheckoutDealsSection> createState() => _CheckoutDealsSectionState();
}

class _CheckoutDealsSectionState extends State<CheckoutDealsSection> {
  late Future<List<Product>> _futureTrendingProducts;

  @override
  void initState() {
    super.initState();
    _futureTrendingProducts = fetchTrendingProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: OrientationBuilder(
        builder: (context, orientation) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                const Text(
                  "Before you checkout",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                beforeCheckout(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget beforeCheckout() {
    return FutureBuilder<List<Product>>(
      future: _futureTrendingProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No deals found.'));
        }

        final products = snapshot.data!;

        return OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;
            final size = MediaQuery.of(context).size;
            final shortestSide = size.shortestSide;
            final screenWidth = size.width;

            /// Make card width smaller in landscape
            final cardWidth = isPortrait
                ? screenWidth * 0.4
                : screenWidth * 0.22;

            /// Image height proportional to card width
            final imageHeight = isPortrait ? cardWidth * 0.6 : cardWidth * 0.4;

            /// Keep font size same as before (no change)
            final fontSize = shortestSide * 0.035;

            return Container(
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                //   colors: [Colors.white, CustomColors.baseContainer],
                // ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              // padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                                          ).then((_) {
                                            // After bottom sheet closes, notify parent
                                            widget.onProductAdded();
                                          });
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
                ],
              ),
            );
          },
        );
      },
    );
  }
}
