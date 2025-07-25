import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/getxcontroller/allgrocery_controller.dart';
import 'package:pakket/getxcontroller/home_ad_controller.dart';
import 'package:pakket/getxcontroller/home_controller.dart';
import 'package:pakket/view/allgrocery.dart';
import 'package:pakket/view/home/carousal.dart';
import 'package:pakket/view/home/shimmer_loader.dart';
import 'package:pakket/view/home/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final HomeAdController adController = Get.put(HomeAdController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Load all required data when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInitialData(); // make sure this exists in your controller
    });

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: Obx(() {
          if (!controller.isAllDataLoaded.value) {
            return const HomeShimmerLoader();
          }

          final selectedCategoryName = controller
              .categories[controller.selectedCategoryIndex.value]
              .name;

          return SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  // Header + Gradient Background + Carousel
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFE9D011).withOpacity(0.40),
                          const Color(0xFFE9D011).withOpacity(0.13),
                          const Color(0xFFFFFFFF).withOpacity(0.72),
                        ],
                        stops: [0.0, 0.92, 1.0],
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Obx(
                            () => buildHeader(
                              context,
                              controller.locationStatus,
                              controller.currentAddressLine1.value,
                              controller.currentAddressLine2.value,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 45,
                                  child: TextFormField(
                                    readOnly: true,
                                    onTap: () => Get.toNamed('/search'),
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: CustomColors.baseColor,
                                          width: 2,
                                        ),
                                      ),
                                      hintText: 'Search',
                                      prefixIcon: Image.asset(
                                        'assets/home/icon.png',
                                      ),
                                      filled: true,
                                      fillColor: CustomColors.textformfield,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ScrollCardCarousel(),
                      ],
                    ),
                  ),

                  // Category List
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      height: screenHeight * 0.12,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.categories.length,
                        itemBuilder: (context, index) {
                          final category = controller.categories[index];
                          final isSelected =
                              controller.selectedCategoryIndex.value == index;

                          return GestureDetector(
                            onTap: () {
                              controller.selectedCategoryIndex.value = index;
                              controller.setSelectedCategory(category);
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03,
                                    vertical: screenWidth * 0.015,
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.01,
                                  ),
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                        )
                                      : null,
                                  child: Image.network(
                                    category.iconUrl,
                                    width: screenWidth * 0.1,
                                    height: screenWidth * 0.1,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.01),
                                Column(
                                  children: [
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        height: 3,
                                        child: LayoutBuilder(
                                          builder: (context, _) {
                                            final textPainter = TextPainter(
                                              text: TextSpan(
                                                text: category.name,
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.038,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              maxLines: 1,
                                              textDirection: TextDirection.ltr,
                                            )..layout();

                                            return SizedBox(
                                              width: textPainter.width,
                                              height: 3,
                                              child: Container(
                                                color: Colors.orange,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // See All Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: buildCategoryHeader(
                      context,
                      selectedCategoryName,
                      'See All',
                      () {
                        Get.put(
                          AllGroceryController(
                            initialCategory: selectedCategoryName,
                          ),
                          tag: selectedCategoryName,
                        );
                        Get.to(
                          () => AllGroceryItems(
                            title: selectedCategoryName,
                            fromBottomNav: false,
                          ),
                        );
                      },
                    ),
                  ),

                  // Product Grid
                  FutureBuilder(
                    future: controller.selectedCategoryProducts.value,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No products found.'));
                      }
                      return buildProductGrid(snapshot.data!);
                    },
                  ),

                  // Sponsored Banner
                  Obx(() {
                    final banner = adController.homeBanner.value;
                    if (banner == null) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Sponsored Advertisement',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 6),
                          InkWell(
                            onTap: () {
                              if (banner.redirectUrl.isNotEmpty) {
                                launchUrl(Uri.parse(banner.redirectUrl));
                              }
                            },
                            child: SizedBox(
                              width: screenWidth,
                              height: 200,
                              child: Image.network(
                                banner.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Trending Products
                  Obx(
                    () =>
                        showTrendingProduct(controller.trendingProducts.value),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
