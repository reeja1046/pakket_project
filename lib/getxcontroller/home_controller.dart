import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pakket/controller/category.dart';
import 'package:pakket/controller/randomproduct.dart';
import 'package:pakket/controller/trending.dart';
import 'package:pakket/model/allcategory.dart';
import 'package:pakket/model/trending.dart';
import 'package:pakket/view/widget/locationpermission.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  var selectedCategoryIndex = 0.obs;
  var currentAddressLine1 = 'Fetching location...'.obs;
  var currentAddressLine2 = ''.obs;

  var categories = <Category>[].obs;
  var selectedCategoryProducts = Future.value(<CategoryProduct>[]).obs;
  var trendingProducts = Future.value(<Product>[]).obs;

  bool isDialogVisible = false;

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    super.onInit();
    getCurrentLocation();
    trendingProducts.value = fetchTrendingProducts();
    fetchCategories().then((fetchedCategories) {
      categories.value = fetchedCategories;
      if (fetchedCategories.isNotEmpty) {
        setSelectedCategory(fetchedCategories[selectedCategoryIndex.value]);
      }
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && isDialogVisible) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        Get.back(); // Close dialog
        isDialogVisible = false;
        getCurrentLocation();
      }
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await determinePosition();
      double lat = position.latitude;
      double lon = position.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      saveLocation(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String addressLine1 = place.postalCode ?? '';
        String addressLine2 =
            '${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
        currentAddressLine1.value = addressLine2;
        currentAddressLine2.value = addressLine1;
      }
    } catch (e) {
      currentAddressLine1.value = 'Failed to get location';
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      isDialogVisible = true;
      showBlurAlertDialog(
        Get.context!,
        'Location Service Disabled',
        'Please enable location services in your device settings.',
        getCurrentLocation,
      );
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> saveLocation(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', lat);
    await prefs.setDouble('longitude', lon);
  }

  void setSelectedCategory(Category category) {
    selectedCategoryProducts.value = category.name.toLowerCase() == 'all items'
        ? fetchRandomProducts(8)
        : fetchProductsByCategory(category.id);
  }
}
