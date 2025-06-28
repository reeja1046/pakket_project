// all_grocery_items.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakket/controller/product.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/getxcontroller/allgrocery_controller.dart';
import 'package:pakket/view/product/productdetails.dart';
import 'package:pakket/view/search/search.dart';
import 'package:pakket/view/widget/bottomnavbar.dart';
import 'package:pakket/view/widget/modal.dart';

class AllGroceryItems extends StatelessWidget {
  final String title;

  AllGroceryItems({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllGroceryController(initialCategory: title));

    return Scaffold(
      backgroundColor: CustomColors.scaffoldBgClr,
      appBar: AppBar(
        backgroundColor: CustomColors.scaffoldBgClr,
        title: Obx(
          () => Text(
            controller.selectedCategoryName.value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () =>
              Get.offAll(() => BottomNavScreen()), // prevent stacking
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/home/icon.png'),
            onPressed: () {
              Get.to(() => SearchDetails());
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            /// LEFT - Categories
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    final isSelected =
                        category.id == controller.selectedCategoryId.value;

                    return GestureDetector(
                      onTap: () {
                        controller.fetchProducts(category.id, category.name);
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
            ),

            /// RIGHT - Product Grid
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.products.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }

                  return GridView.builder(
                    itemCount: controller.products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.5,
                        ),
                    itemBuilder: (context, index) {
                      final product = controller.products[index];
                      final option = product.options.first;

                      return GestureDetector(
                        onTap: () {
                          Get.to(
                            () => ProductDetails(productId: product.productId),
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
                                    onPressed: () async {
                                      final productDetail =
                                          await fetchProductDetail(
                                            product.productId,
                                          );
                                      showProductOptionBottomSheet(
                                        context: context,
                                        product: productDetail,
                                      );
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
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
