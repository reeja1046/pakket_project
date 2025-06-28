import 'package:flutter/material.dart';
import 'package:pakket/controller/product.dart';
import 'package:pakket/controller/trending.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/trending.dart';
import 'package:pakket/view/product/productdetails.dart';
import 'package:pakket/view/widget/modal.dart';

class CheckoutDealsSection extends StatefulWidget {
  const CheckoutDealsSection({super.key});

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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            const Text(
              "Before you checkout",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.28,
              child: FutureBuilder<List<Product>>(
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

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final option = product.options.first;

                      double screenWidth = MediaQuery.of(context).size.width;
                      double cardWidth = screenWidth * 0.45;
                      double imageHeight = screenWidth * 0.25;
                      double fontSize = screenWidth * 0.035;

                      return Container(
                        margin: EdgeInsets.only(right: screenWidth * 0.025),
                        width: cardWidth,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetails(productId: product.id),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      color: CustomColors.baseContainer,
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.15,
                                      width: screenWidth,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Image.network(
                                          product.thumbnail,
                                          height: imageHeight,
                                          width: double.infinity,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.02),
                                  Text(
                                    product.title,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: screenWidth * 0.01),
                                  Text(
                                    option.unit,
                                    style: TextStyle(
                                      fontSize: fontSize * 0.9,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Rs.${option.offerPrice.floor()}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Rs.${option.basePrice.floor()}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: Colors.black,
                                          decorationThickness: 2,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final productDetail =
                                              await fetchProductDetail(
                                                product.id,
                                              );
                                          showProductOptionBottomSheet(
                                            context: context,
                                            product:
                                                productDetail, // Make sure this is the correct ProductDetail object
                                          );
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: CustomColors.baseColor,
                                            borderRadius: BorderRadius.circular(
                                              7,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Add',
                                              style: TextStyle(
                                                fontSize: fontSize * 0.9,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          ],
        ),
      ),
    );
  }
}
