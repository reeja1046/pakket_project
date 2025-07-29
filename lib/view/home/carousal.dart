import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakket/getxcontroller/allgrocery_controller.dart';
import 'package:pakket/getxcontroller/home_carousal_controller.dart';
import 'package:pakket/view/allgrocery.dart';

class ScrollCardCarousel extends StatelessWidget {
  ScrollCardCarousel({super.key});

  final CarouselHomeController carouselController = Get.put(
    CarouselHomeController(),
  );

  @override
  Widget build(BuildContext context) {
    // Detect orientation
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Calculate height based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final carouselHeight = isPortrait
        ? screenWidth * 0.5
        : screenWidth * 0.4; // dynamic ratio

    return Obx(() {
      if (carouselController.banners.isEmpty) {
        return SizedBox(
          height: carouselHeight,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return SizedBox(
        height: carouselHeight,
        child: PageView.builder(
          controller: carouselController.pageController,
          itemCount: carouselController.banners.length,
          onPageChanged: carouselController.onPageChanged,
          itemBuilder: (context, index) {
            final banner = carouselController.banners[index];
            final selectedCategoryName = banner.categoryname;

            return GestureDetector(
              onTap: () {
                // Set controller with tag for selected category
                Get.put(
                  AllGroceryController(initialCategory: selectedCategoryName),
                  tag: selectedCategoryName,
                );

                // Navigate to All Grocery Items page
                Get.to(
                  () => AllGroceryItems(
                    title: selectedCategoryName,
                    fromBottomNav: false,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ClipRRect(
                  child: Image.network(
                    banner.url,
                    fit: BoxFit.fill, // fills without stretching
                    errorBuilder: (_, __, ___) => const Icon(Icons.error),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
