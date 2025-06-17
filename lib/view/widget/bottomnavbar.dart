import 'package:flutter/material.dart';
import 'package:pakket/view/checkout.dart';
import 'package:pakket/view/home/home.dart';
import 'package:pakket/view/order.dart';
import 'package:pakket/view/wishlist.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    WishlistScreen(),
    CheckoutScreen(),
    OrderScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
              'assets/logo/orders.png',
              width: 24,
              color: Colors.orange,
              colorBlendMode: BlendMode.srcIn,
            ),
            label: "",
          ),
        ],
      ),
    );
  }
}
