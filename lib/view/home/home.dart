import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pakket/controller/category.dart';
import 'package:pakket/controller/randomproduct.dart';
import 'package:pakket/controller/trending.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/allcategory.dart';
import 'package:pakket/model/trending.dart';
import 'package:pakket/view/allgrocery.dart';
import 'package:pakket/view/home/widget.dart';
import 'package:pakket/view/widget/locationpermission.dart';
import 'package:shared_preferences/shared_preferences.dart';

int selectedCategoryIndex = 0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late Future<List<Category>> _categoriesFuture;
  late Future<List<CategoryProduct>> _selectedCategoryProducts;
  late Future<List<Product>> _trendingProducts;
  String currentAddressLine1 = 'Fetching location...';
  String currentAddressLine2 = '';
  bool isDialogVisible = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this); // 👉 Add Observer
    getCurrentLocation();
    super.initState();

    _trendingProducts = fetchTrendingProducts();
    _categoriesFuture = fetchCategories();
    _categoriesFuture.then((categories) {
      if (categories.isNotEmpty) {
        _setSelectedCategory(categories[selectedCategoryIndex]);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 👉 Remove Observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && isDialogVisible) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
        isDialogVisible = false;
        getCurrentLocation(); // Auto-retry location fetch
      }
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await determinePosition(context);
      // await _getAddressFromLatLng(position);
      double lat = position.latitude;
      double lon = position.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      saveLocation(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String addressLine1 = place.postalCode ?? '';
        String addressLine2 =
            '${place.locality ?? ''}, ${place.administrativeArea ?? ''}';

        setState(() {
          currentAddressLine1 = addressLine2;
          currentAddressLine2 = addressLine1;
        });
      }
    } catch (e) {
      setState(() {
        currentAddressLine1 = 'Failed to get location';
      });
    }
  }

  Future<Position> determinePosition(context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      isDialogVisible = true;
      showBlurAlertDialog(
        context,
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
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> saveLocation(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', lat);
    await prefs.setDouble('longitude', lon);
  }

  void _setSelectedCategory(Category category) {
    setState(() {
      _selectedCategoryProducts = category.name.toLowerCase() == 'all items'
          ? fetchRandomProducts(8)
          : fetchProductsByCategory(category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // Close the app
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x66CAD980),
                        Color(0x21CCDA86),
                        Color(0xB7FFFFFF),
                      ],
                      stops: [0.0, 0.95, 0.100],
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: buildHeader(
                          context,
                          currentAddressLine1,
                          currentAddressLine2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 45,
                                child: TextFormField(
                                  readOnly: true,
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushNamed('/search'),
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: CustomColors.baseColor,
                                        width: 2,
                                      ),
                                    ),
                                    hintText: 'Search',
                                    prefixIcon: Image.asset(
                                      'assets/home/icon.png',
                                    ),
                                    filled: true,
                                    fillColor: CustomColors.textformfield,
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(width: 10),
                            // Container(
                            //   height: 45,
                            //   width: 50,
                            //   decoration: BoxDecoration(
                            //     color: CustomColors.baseColor,
                            //     borderRadius: BorderRadius.circular(10),
                            //   ),
                            //   child: IconButton(
                            //     onPressed: () {},
                            //     icon: Image.asset('assets/home/setting-4.png'),
                            //     padding: EdgeInsets.zero,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      ScrollCardCarousel(),
                    ],
                  ),
                ),
                FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No categories found"));
                    }

                    final categories = snapshot.data!;
                    final selectedCategoryName =
                        categories[selectedCategoryIndex].name;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SizedBox(
                            height: screenHeight * 0.12,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final isSelected =
                                    selectedCategoryIndex == index;

                                return GestureDetector(
                                  onTap: () {
                                    selectedCategoryIndex = index;
                                    _setSelectedCategory(category);
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.03,
                                          vertical: screenWidth * 0.015,
                                        ),
                                        margin: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.01,
                                        ),
                                        decoration: isSelected
                                            ? BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        10,
                                                      ),
                                                      topRight: Radius.circular(
                                                        10,
                                                      ),
                                                    ),
                                              )
                                            : null,
                                        child: Image.network(
                                          category.iconUrl,
                                          width: screenWidth * 0.1,
                                          height: screenWidth * 0.1,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      SizedBox(height: screenWidth * 0.01),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: screenWidth * 0.12,
                                          height: 3,
                                          color: Colors.orange,
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: buildCategoryHeader(
                            context,
                            selectedCategoryName,
                            'see All',
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AllGroceryItems(
                                  title: selectedCategoryName,
                                ),
                              ),
                            ),
                          ),
                        ),
                        FutureBuilder<List<CategoryProduct>>(
                          future: _selectedCategoryProducts,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('No products found.'),
                              );
                            }
                            return buildProductGrid(snapshot.data!);
                          },
                        ),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: SizedBox(
                    width: screenWidth,
                    height: 240,
                    child: Image.asset(
                      'assets/home/reward-Ad.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                showTrendingProduct(_trendingProducts),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
