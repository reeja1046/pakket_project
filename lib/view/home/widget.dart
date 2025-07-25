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
          Image.asset('assets/logo.png', height: height * 0.05),
          SizedBox(width: height * 0.045),
          Image.asset('assets/logo_text.png', height: height * 0.05),
          const Spacer(),
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

// class ScrollCardCarousel extends StatefulWidget {
//   const ScrollCardCarousel({super.key});

//   @override
//   State<ScrollCardCarousel> createState() => _ScrollCardCarouselState();
// }

// class _ScrollCardCarouselState extends State<ScrollCardCarousel> {
//   late PageController controller;
//   int currentIndex = 0;
//   Timer? timer;

//   @override
//   void initState() {
//     super.initState();
//     controller = PageController(viewportFraction: 0.85);
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     timer?.cancel();
//     super.dispose();
//   }

//   void startAutoScroll(List<HeroBanner> banners) {
//     timer?.cancel();
//     timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (controller.hasClients) {
//         if (currentIndex < banners.length - 1) {
//           currentIndex++;
//         } else {
//           currentIndex = 0;
//         }
//         controller.animateToPage(
//           currentIndex,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<HeroBanner>>(
//       future: fetchHeroBanners(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SizedBox(
//             height: 240,
//             child: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.hasError) {
//           return const SizedBox(
//             height: 240,
//             child: Center(child: Text('Failed to load banners')),
//           );
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const SizedBox(
//             height: 240,
//             child: Center(child: Text('No banners available')),
//           );
//         }

//         final banners = snapshot.data!;
//         startAutoScroll(banners);

//         return buildScrollCard(context, banners);
//       },
//     );
//   }

//   Widget buildScrollCard(BuildContext context, List<HeroBanner> banners) {
//     return SizedBox(
//       height: 240,
//       child: PageView.builder(
//         controller: controller,
//         itemCount: banners.length,
//         onPageChanged: (index) {
//           currentIndex = index;
//         },
//         itemBuilder: (context, index) {
//           final banner = banners[index];
//           return GestureDetector(
//             onTap: () => Get.find<BottomNavController>().changeIndex(1),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   banner.url,
//                   fit: BoxFit.contain,
//                   errorBuilder: (_, __, ___) => const Icon(Icons.error),
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return const Center(child: CircularProgressIndicator());
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

Widget buildCategoryHeader(
  BuildContext context,
  String title,
  String title2,
  VoidCallback onSeeAllPressed,
) {
  final screenWidth = MediaQuery.of(context).size.width;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.bold,
        ),
      ),
      GestureDetector(
        onTap: onSeeAllPressed,
        child: Text(
          title2,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
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
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: displayProducts.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.62,
    ),
    padding: const EdgeInsets.all(14),
    itemBuilder: (context, index) {
      final product = displayProducts[index];
      return GestureDetector(
        onTap: () async {
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
              height: 75,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
      final screenWidth = MediaQuery.of(context).size.width;
      final imageHeight = screenWidth * 0.25;
      final fontSize = screenWidth * 0.035;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, CustomColors.baseContainer],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(products.length, (index) {
                  final product = products[index];
                  final option = product.options.first;

                  return Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: GestureDetector(
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
                        margin: EdgeInsets.only(right: screenWidth * 0.025),
                        width: screenWidth * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: CustomColors.baseContainer,
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  width: 80,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: CustomColors.baseColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final productDetail =
                                          await fetchProductDetail(product.id);
                                      showProductOptionBottomSheet(
                                        context: context,
                                        product:
                                            productDetail, // Make sure this is the correct ProductDetail object
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
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    },
  );
}
