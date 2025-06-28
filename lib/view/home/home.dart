import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/getxcontroller/home_controller.dart';
import 'package:pakket/view/allgrocery.dart';
import 'package:pakket/view/home/widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
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
                        child: Obx(
                          () => buildHeader(
                            context,
                            controller.currentAddressLine1.value,
                            controller.currentAddressLine2.value,
                          ),
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
                                  onTap: () => Get.toNamed('/search'),
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
                Obx(() {
                  if (controller.categories.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final selectedCategoryName = controller
                      .categories[controller.selectedCategoryIndex.value]
                      .name;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: SizedBox(
                          height: screenHeight * 0.12,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.categories.length,
                            itemBuilder: (context, index) {
                              final category = controller.categories[index];
                              final isSelected =
                                  controller.selectedCategoryIndex.value ==
                                  index;

                              return GestureDetector(
                                onTap: () {
                                  controller.selectedCategoryIndex.value =
                                      index;
                                  controller.setSelectedCategory(category);
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
                          () => Get.to(
                            () => AllGroceryItems(title: selectedCategoryName),
                          ),
                        ),
                      ),
                      FutureBuilder(
                        future: controller.selectedCategoryProducts.value,
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
                }),
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
                Obx(
                  () => showTrendingProduct(controller.trendingProducts.value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
