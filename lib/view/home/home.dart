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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInitialData();
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

          return OrientationBuilder(
            builder: (context, orientation) {
              final isPortrait = orientation == Orientation.portrait;
              final size = MediaQuery.of(context).size;

              // Category height & icon size adaptive
              final categoryHeight = isPortrait ? 110.0 : 110.0;
              final iconSize = isPortrait ? 40.0 : 40.0;

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// Header + Gradient + Carousel
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
                            stops: const [0.0, 0.92, 1.0],
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                              ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                              ),
                              child: SizedBox(
                                height: 45,
                                child: TextFormField(
                                  readOnly: true,
                                  onTap: () => Get.toNamed('/search'),
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
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
                            const SizedBox(height: 20),
                            ScrollCardCarousel(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      /// Category List
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: SizedBox(
                          height: categoryHeight,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.categories.length,
                            itemBuilder: (context, index) {
                              final category = controller.categories[index];
                              final isSelected =
                                  controller.selectedCategoryIndex.value ==
                                  index;

                              return GestureDetector(
                                onTap: () {
                                  controller.selectedCategoryIndex.value =
                                      index;
                                  controller.setSelectedCategory(category);
                                },

                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: isSelected
                                            ? BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        10,
                                                      ),
                                                      topRight: Radius.circular(
                                                        10,
                                                      ),
                                                    ),
                                              )
                                            : null,
                                        child: Image.network(
                                          category.iconUrl,
                                          width: iconSize,
                                          height: iconSize,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          height: 3,
                                          width: category.name.length * 8.0,
                                          color: Colors.orange,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      /// See All Button
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
                      SizedBox(height: 20),

                      /// Product Grid
                      FutureBuilder(
                        future: controller.selectedCategoryProducts.value,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('No products found.'),
                              ),
                            );
                          }

                          return buildProductGrid(snapshot.data!);
                        },
                      ),

                      /// Sponsored Banner
                      Obx(() {
                        final banner = adController.homeBanner.value;
                        if (banner == null) return const SizedBox.shrink();

                        final size = MediaQuery.of(context).size;
                        final isPortrait =
                            MediaQuery.of(context).orientation ==
                            Orientation.portrait;

                        // Dynamic dimensions
                        final bannerWidth = size.width;
                        final bannerHeight = isPortrait
                            ? bannerWidth * 0.5
                            : bannerWidth * 0.45;
                        // shorter in landscape

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
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () {
                                  if (banner.redirectUrl.isNotEmpty) {
                                    launchUrl(Uri.parse(banner.redirectUrl));
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: bannerWidth,
                                    height: bannerHeight,
                                    child: Image.network(
                                      banner.imageUrl,
                                      fit: BoxFit
                                          .cover, // cover looks better for banners
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      /// Trending Products
                      Obx(
                        () => showTrendingProduct(
                          controller.trendingProducts.value,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
