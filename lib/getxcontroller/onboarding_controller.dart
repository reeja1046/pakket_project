import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakket/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  final PageController pageController = PageController();

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Buy Groceries Easily\nwith Us',
      'description':
          'It is a long established fact that a reader\nwill be distracted by the readable',
      'image': 'assets/splash/grocery.png',
    },
    {
      'title': 'Fresh Fruits & Vegetables\nDelivered Daily',
      'description':
          'Get farm-fresh fruits and vegetables\ndelivered to your doorstep.',
      'image': 'assets/splash/veg-splash.png',
    },
    {
      'title': 'Quick & Secure Delivery\nfor Non-Veg Items',
      'description':
          'Order fresh meat and seafood\nwith safe and fast delivery.',
      'image': 'assets/splash/nonveg-splash.png',
    },
  ];

  void nextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offNamed(AppRoutes.signup);
    }
  }

  void skip() {
    Get.offNamed(AppRoutes.signup);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
