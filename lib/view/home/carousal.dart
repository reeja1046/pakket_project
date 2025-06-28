import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakket/getxcontroller/home_carousal_controller.dart';

class ScrollCardCarousel extends StatelessWidget {
  ScrollCardCarousel({super.key});

  final CarouselHomeController carouselController = Get.put(
    CarouselHomeController(),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (carouselController.banners.isEmpty) {
        return const SizedBox(
          height: 240,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return SizedBox(
        height: 240,
        child: PageView.builder(
          controller: carouselController.pageController,
          itemCount: carouselController.banners.length,
          onPageChanged: carouselController.onPageChanged,
          itemBuilder: (context, index) {
            final banner = carouselController.banners[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  banner.url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
