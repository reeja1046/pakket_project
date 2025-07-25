import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakket/controller/herobanner.dart';
import 'package:pakket/model/herobanner.dart';

class CarouselHomeController extends GetxController {
  var banners = <HeroBanner>[].obs;
  var currentIndex = 0.obs;

  late PageController pageController;
  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.85);
    fetchBanners();
  }

  void fetchBanners() async {
    try {
      final data = await fetchHeroBanners();
     
      if (data.isNotEmpty) {
        banners.assignAll(data);
        startAutoScroll();
      }
    } catch (e) {
      // Handle errors if needed
    }
  }

  void startAutoScroll() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pageController.hasClients && banners.isNotEmpty) {
        if (currentIndex.value < banners.length - 1) {
          currentIndex.value++;
        } else {
          currentIndex.value = 0;
        }
        pageController.animateToPage(
          currentIndex.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    timer?.cancel();
    super.onClose();
  }
}
