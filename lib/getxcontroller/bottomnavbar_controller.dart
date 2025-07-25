import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;
  var keys = <int, Key>{
    0: UniqueKey(),
    1: UniqueKey(),
    2: UniqueKey(),
    3: UniqueKey(),
  }.obs;

  void changeIndex(int index) {
    // Refresh Home, Checkout, and Orders
    if (index == 0 || index == 2 || index == 3) {
      keys[index] = UniqueKey();
    }
    // Do not refresh All Grocery Items (index == 1)
    selectedIndex.value = index;
  }
}
