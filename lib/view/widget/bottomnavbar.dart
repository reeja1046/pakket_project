import 'package:flutter/material.dart';
import 'package:pakket/view/allgrocery.dart';
import 'package:pakket/view/checkout/checkout.dart';
import 'package:pakket/view/home/home.dart';
import 'package:pakket/view/order.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(),
      AllGroceryItems(title: 'All items'),
      CheckoutPage(fromBottomNav: true, onBack: () => onItemTapped(0)),
      OrderScreen(fromBottomNav: true, onBack: () => onItemTapped(0)),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          // If not on home page, go to home page
          setState(() {
            _selectedIndex = 0;
          });
          return false; // Don't pop the page
        }
        return true; // If on home page, allow back action (exit app)
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: onItemTapped,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/bottomnavbar/home.png',
                width: 24,
                color: Colors.black,
                colorBlendMode: BlendMode.srcIn,
              ),
              activeIcon: Image.asset(
                'assets/bottomnavbar/home.png',
                width: 24,
                color: Colors.orange,
                colorBlendMode: BlendMode.srcIn,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/bottomnavbar/Vector.png',
                width: 22,
                color: Colors.black,
                colorBlendMode: BlendMode.srcIn,
              ),
              activeIcon: Image.asset(
                'assets/bottomnavbar/Vector.png',
                width: 22,
                color: Colors.orange,
                colorBlendMode: BlendMode.srcIn,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/bottomnavbar/bag.png',
                width: 24,
                color: Colors.black,
                colorBlendMode: BlendMode.srcIn,
              ),
              activeIcon: Image.asset(
                'assets/bottomnavbar/bag.png',
                width: 24,
                color: Colors.orange,
                colorBlendMode: BlendMode.srcIn,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/bottomnavbar/orders.png',
                width: 24,
                color: Colors.black,
                colorBlendMode: BlendMode.srcIn,
              ),
              activeIcon: Image.asset(
                'assets/bottomnavbar/orders.png',
                width: 24,
                color: Colors.orange,
                colorBlendMode: BlendMode.srcIn,
              ),
              label: "",
            ),
          ],
        ),
      ),
    );
  }
}
