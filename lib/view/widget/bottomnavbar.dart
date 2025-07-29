import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/getxcontroller/bottomnavbar_controller.dart';
import 'package:pakket/view/allgrocery.dart';
import 'package:pakket/view/checkout/checkout.dart';
import 'package:pakket/view/home/home.dart';
import 'package:pakket/view/order.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomNavScreen extends StatelessWidget {
  BottomNavScreen({super.key});

  final BottomNavController controller = Get.put(BottomNavController());

  // Only real screens (exclude WhatsApp)
  final List<Widget> _screens = [
    const HomeScreen(),
    AllGroceryItems(title: 'All items', fromBottomNav: true),
    CheckoutPage(fromBottomNav: true),
    OrderScreen(fromBottomNav: true),
  ];

  /// Function to launch WhatsApp
  Future<void> _openWhatsApp() async {
    const phone = "+918089996656"; // Replace with your WhatsApp number
    final url = Uri.parse("https://wa.me/$phone");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Error",
        "WhatsApp is not installed or cannot be opened",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.selectedIndex.value != 0) {
          controller.changeIndex(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Obx(
          () => IndexedStack(
            index: controller.selectedIndex.value,
            children: [
              KeyedSubtree(key: controller.keys[0], child: _screens[0]),
              KeyedSubtree(key: controller.keys[1], child: _screens[1]),
              KeyedSubtree(key: controller.keys[2], child: _screens[2]),
              KeyedSubtree(key: controller.keys[3], child: _screens[3]),
            ],
          ),
        ),

        bottomNavigationBar: Obx(() {
          final selectedIndex = controller.selectedIndex.value;

          return BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: selectedIndex >= 2
                ? selectedIndex + 1
                : selectedIndex, // Shift highlight
            onTap: (index) async {
              if (index == 2) {
                // WhatsApp - do not change selectedIndex
                await _openWhatsApp();
              } else if (index > 2) {
                // Adjust index after WhatsApp
                controller.changeIndex(index - 1);
              } else {
                controller.changeIndex(index);
              }
            },
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/bottomnavbar/home.png',
                  width: 24,
                  color: selectedIndex == 0
                      ? CustomColors.baseColor
                      : Colors.black,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/bottomnavbar/Vector.png',
                  width: 22,
                  color: selectedIndex == 1
                      ? CustomColors.baseColor
                      : Colors.black,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                // WhatsApp: Always black (non-selectable)
                icon: Image.asset(
                  'assets/wtsp.png',
                  width: 26,
                  color: Colors.black,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/bottomnavbar/bag.png',
                  width: 24,
                  color: selectedIndex == 2
                      ? CustomColors.baseColor
                      : Colors.black,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/bottomnavbar/orders.png',
                  width: 24,
                  color: selectedIndex == 3
                      ? CustomColors.baseColor
                      : Colors.black,
                ),
                label: "",
              ),
            ],
          );
        }),
      ),
    );
  }
}
