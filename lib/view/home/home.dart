import 'package:flutter/material.dart';
import 'package:pakket/controller/category.dart';
import 'package:pakket/controller/randomproduct.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/allcategory.dart';
import 'package:pakket/view/home/widget.dart';

int selectedCategoryIndex = 0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Category>>? _categoriesFuture;
  Future<List<CategoryProduct>>? _selectedCategoryProducts;

  @override
  void initState() {
    // _trendingProducts = fetchTrendingProducts();
    _categoriesFuture = fetchCategories();
    print('***----****');
    print(_categoriesFuture);
    _categoriesFuture!.then((categories) {
      if (categories.isNotEmpty) {
        final defaultCategory = categories[selectedCategoryIndex];
        setState(() {
          if (defaultCategory.name.toLowerCase() == 'all items') {
            _selectedCategoryProducts = fetchRandomProducts(8);
          } else {
            _selectedCategoryProducts = fetchProductsByCategory(
              defaultCategory.id,
            );
          }
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Yellow background section
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66CAD980), // 40% opacity
                    Color(0x21CCDA86), // 13% opacity
                    Color(0xB7FFFFFF), // full white
                  ],
                  stops: [0.0, 0.95, 0.100],
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0, right: 14.0),
                    child: buildHeader(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0, right: 14.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: TextFormField(
                              readOnly: true,
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => SearchDetails()),
                                // );
                              },
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: CustomColors.baseColor,
                                    width: 2,
                                  ),
                                ),
                                hintText: 'Search',
                                prefixIcon: Image.asset('assets/home/icon.png'),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 45,
                          width: 50,
                          decoration: BoxDecoration(
                            color: CustomColors.baseColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Image.asset('assets/home/setting-4.png'),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Start of scroll card and rest of the white background UI
                  showScrollCard(),
                ],
              ),
            ),
            FutureBuilder(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                print('**************////////');
                print(snapshot.data);
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
                        height: size.height * 0.12,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            bool isSelected = selectedCategoryIndex == index;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategoryIndex = index;
                                  if (category.name.toLowerCase() ==
                                      'all items') {
                                    _selectedCategoryProducts =
                                        fetchRandomProducts(8);
                                  } else {
                                    _selectedCategoryProducts =
                                        fetchProductsByCategory(category.id);
                                  }
                                });
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
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
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
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AllGroceryItems(),
                            ),
                          );
                        },
                      ),
                    ),
                     FutureBuilder<List<CategoryProduct>>(
                        future: _selectedCategoryProducts,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No products found.'));
                          }

                          final products = snapshot.data!;
                          return buildProductGrid(products);
                        },
                      )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
