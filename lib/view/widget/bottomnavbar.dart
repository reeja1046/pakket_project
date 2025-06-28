import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakket/getxcontroller/bottomnavbar_controller.dart';
import 'package:pakket/view/allgrocery.dart';
import 'package:pakket/view/checkout/checkout.dart';
import 'package:pakket/view/home/home.dart';
import 'package:pakket/view/order.dart';

class BottomNavScreen extends StatelessWidget {
  BottomNavScreen({super.key});

  final BottomNavController controller = Get.put(BottomNavController());

  final List<Widget> _screens = [
    const HomeScreen(),
   AllGroceryItems(title: 'All items', fromBottomNav: true),

    CheckoutPage(fromBottomNav: true),
    OrderScreen(fromBottomNav: true),
  ];

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
            children: _screens,
          ),
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeIndex,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/bottomnavbar/home.png',
                  width: 24,
                  color: Colors.black,
                ),
                activeIcon: Image.asset(
                  'assets/bottomnavbar/home.png',
                  width: 24,
                  color: Colors.orange,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/bottomnavbar/Vector.png',
                  width: 22,
                  color: Colors.black,
                ),
                activeIcon: Image.asset(
                  'assets/bottomnavbar/Vector.png',
                  width: 22,
                  color: Colors.orange,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/bottomnavbar/bag.png',
                  width: 24,
                  color: Colors.black,
                ),
                activeIcon: Image.asset(
                  'assets/bottomnavbar/bag.png',
                  width: 24,
                  color: Colors.orange,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/bottomnavbar/orders.png',
                  width: 24,
                  color: Colors.black,
                ),
                activeIcon: Image.asset(
                  'assets/bottomnavbar/orders.png',
                  width: 24,
                  color: Colors.orange,
                ),
                label: "",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
