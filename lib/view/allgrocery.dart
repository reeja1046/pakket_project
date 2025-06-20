import 'package:flutter/material.dart';
import 'package:pakket/core/constants/appbar.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/allcategory.dart';
import 'package:pakket/controller/category.dart';

class AllGroceryItems extends StatefulWidget {
  const AllGroceryItems({super.key});

  @override
  State<AllGroceryItems> createState() => _AllGroceryItemsState();
}

class _AllGroceryItemsState extends State<AllGroceryItems> {
  final ScrollController categoryScrollController = ScrollController();

  List<Category> categories = [];
  List<CategoryProduct> products = [];
  String? selectedCategoryId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      final fetchedCategories = await fetchCategories();
      setState(() {
        categories = fetchedCategories;
        selectedCategoryId = fetchedCategories.first.id;
      });
      fetchProducts(selectedCategoryId!);
    } catch (e) {
      print('Error fetching categories: $e');
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
      print('Error fetching products: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.scaffoldBgClr,
      appBar: buildGroceryAppBar(context, "All grocery items"),
      body: Row(
        children: [
          /// LEFT - Categories
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Scrollbar(
              controller: categoryScrollController,
              thumbVisibility: true,
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
                      });
                      fetchProducts(category.id);
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
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                category.imageUrl,
                                height: 70,
                                width: 70,
                                fit: BoxFit.contain,
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
          ),

          /// RIGHT - Product Grid
          Expanded(
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(10),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.5,
                          ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final option = product.options.first;

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: CustomColors.baseContainer,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Image.network(
                                      product.thumbnail,
                                      height: 80,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.title,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(indent: 10, endIndent: 10),
                                IntrinsicHeight(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        option.unit,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const VerticalDivider(),
                                      Text(
                                        "Rs.${option.offerPrice.floor()}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  height: 30,
                                  width: 80,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: CustomColors.baseColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: () {
                                      // TODO: Handle Add to cart
                                    },
                                    child: const Text(
                                      'Add',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
