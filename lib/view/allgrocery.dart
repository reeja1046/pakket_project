import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakket/controller/product.dart';
import 'package:pakket/controller/randomproduct.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/getxcontroller/bottomnavbar_controller.dart';
import 'package:pakket/model/allcategory.dart';
import 'package:pakket/controller/category.dart';
import 'package:pakket/view/product/productdetails.dart';
import 'package:pakket/view/search/search.dart';
import 'package:pakket/view/widget/modal.dart';

class AllGroceryItems extends StatefulWidget {
  final String title;
  final bool fromBottomNav;

  const AllGroceryItems({
    super.key,
    required this.title,
    required this.fromBottomNav,
  });

  @override
  State<AllGroceryItems> createState() => _AllGroceryItemsState();
}

class _AllGroceryItemsState extends State<AllGroceryItems> {
  final ScrollController categoryScrollController = ScrollController();

  List<Category> categories = [];
  List<CategoryProduct> products = [];
  String? selectedCategoryId;
  bool isLoading = true;
  late String selectedCategoryName;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    selectedCategoryName = widget.title;
  }

  Future<void> fetchInitialData() async {
    try {
      final fetchedCategories = await fetchCategories();
      String? initialCategoryId;
      String initialCategoryName = widget.title;

      // Match category by title
      final matchingCategory = fetchedCategories.firstWhere(
        (category) => category.name.toLowerCase() == widget.title.toLowerCase(),
        orElse: () => fetchedCategories.first,
      );

      initialCategoryId = matchingCategory.id;
      initialCategoryName = matchingCategory.name;

      setState(() {
        categories = fetchedCategories;
        selectedCategoryId = initialCategoryId;
        selectedCategoryName = initialCategoryName;
      });

      // Load products
      if (matchingCategory.name.toLowerCase() == 'all items') {
        fetchAllProducts()
            .then((fetchedProducts) {
              setState(() {
                products = fetchedProducts;
                isLoading = false;
              });
            })
            .catchError((e) {
              Get.snackbar('Error!!','Error fetching products: $e');
              setState(() => isLoading = false);
            });
      } else {
        fetchProducts(initialCategoryId);
      }
    } catch (e) {
      Get.snackbar('Error!!','Error fetching categories: $e');
    }
  }

  Future<void> fetchProducts(String categoryId) async {
    setState(() => isLoading = true);
    try {
      final fetchedProducts = await fetchProductsByCategory(categoryId);
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
     Get.snackbar('Error!!','Error fetching products: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: CustomColors.scaffoldBgClr,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: CustomColors.scaffoldBgClr,
        title: Text(
          selectedCategoryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (widget.fromBottomNav) {
              final bottomNavController = Get.find<BottomNavController>();
              bottomNavController.changeIndex(0);
            } else {
              Get.back();
            }
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/home/icon.png'),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => SearchDetails()));
            },
          ),
          const SizedBox(width: 10),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withOpacity(0.3), height: 1),
        ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            /// LEFT SIDE: Category List
            SizedBox(
              width: isPortrait ? screenWidth * 0.3 : screenWidth * 0.25,
              child: ListView.builder(
                controller: categoryScrollController,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category.id == selectedCategoryId;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryId = category.id;
                        selectedCategoryName = category.name;
                        isLoading = true;
                      });

                      if (category.name.toLowerCase() == 'all items') {
                        fetchRandomProducts(8)
                            .then((fetchedProducts) {
                              setState(() {
                                products = fetchedProducts;
                                isLoading = false;
                              });
                            })
                            .catchError((e) {
                              setState(() => isLoading = false);
                            });
                      } else {
                        fetchProducts(category.id);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CustomColors.scaffoldBgClr,
                        border: Border(
                          right: BorderSide(
                            color: isSelected
                                ? CustomColors.baseColor
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                ),
                                child: Image.network(
                                  category.imageUrl,
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            category.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// RIGHT SIDE: Product Grid
            Expanded(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  final isPortrait = orientation == Orientation.portrait;
                  final size = MediaQuery.of(context).size;
                  final shortestSide = size.shortestSide;

                  return Container(
                    padding: const EdgeInsets.all(10),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                            itemCount: products.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isPortrait
                                      ? 2
                                      : 3, // more columns in landscape
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: isPortrait
                                      ? 0.6
                                      : 0.68, // shorter cards in landscape
                                ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final option = product.options.first;

                              // Dynamic sizes
                              final imageHeight = isPortrait
                                  ? shortestSide * 0.15
                                  : shortestSide * 0.35; // smaller in landscape
                              final fontSize = isPortrait
                                  ? shortestSide * 0.035
                                  : shortestSide * 0.035; // reduce slightly
                              final buttonWidth = isPortrait
                                  ? shortestSide * 0.25
                                  : shortestSide * 0.25;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetails(
                                        productId: product.productId,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        // Product Image
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: CustomColors.baseContainer,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Image.network(
                                                product.thumbnail,
                                                height: imageHeight,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Title
                                        Text(
                                          product.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Divider(
                                          indent: 10,
                                          endIndent: 10,
                                        ),

                                        // Unit & Price
                                        IntrinsicHeight(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                option.unit,
                                                style: TextStyle(
                                                  fontSize: fontSize * 0.8,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const VerticalDivider(),
                                              Text(
                                                "Rs.${option.offerPrice.floor()}",
                                                style: TextStyle(
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),

                                        // Add Button
                                        SizedBox(
                                          height: 30,
                                          width: buttonWidth,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor:
                                                  CustomColors.baseColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            onPressed: () async {
                                              final productDetail =
                                                  await fetchProductDetail(
                                                    product.productId,
                                                  );
                                              showProductOptionBottomSheet(
                                                context: context,
                                                product: productDetail!,
                                              );
                                            },
                                            child: const Text(
                                              'Add',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
