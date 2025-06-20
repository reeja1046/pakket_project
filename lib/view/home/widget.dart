import 'package:flutter/material.dart';
import 'package:pakket/controller/herobanner.dart';
import 'package:pakket/controller/product.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/allcategory.dart';
import 'package:pakket/model/herobanner.dart';
import 'package:pakket/model/trending.dart';
import 'package:pakket/view/product/productdetails.dart';

Widget buildHeader(BuildContext context) {
  final height = MediaQuery.of(context).size.height;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: height * 0.02),
      Row(
        children: [
          Image.asset('assets/logo.png', height: height * 0.05),
          SizedBox(width: height * 0.045),
          Image.asset('assets/logo_text.png', height: height * 0.05),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/profile'),
            child: Image.asset('assets/home/profileicon.png'),
          ),
        ],
      ),
      const SizedBox(height: 10),
      const Text(
        'Your Location',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      Row(
        children: [
          const Text(
            'PVS Green Valley, Chalakunnu, Kannur',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(width: 5),
          Image.asset('assets/home/location.png', color: Colors.black),
        ],
      ),
      const SizedBox(height: 10),
    ],
  );
}

Widget showScrollCard() {
  return FutureBuilder<List<HeroBanner>>(
    future: fetchHeroBanners(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox(
          height: 240,
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (snapshot.hasError) {
        return const SizedBox(
          height: 240,
          child: Center(child: Text('Failed to load banners')),
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const SizedBox(
          height: 240,
          child: Center(child: Text('No banners available')),
        );
      }
      return scrollCard(context, snapshot.data!);
    },
  );
}

Widget scrollCard(BuildContext context, List<HeroBanner> banners) {
  final controller = PageController(initialPage: 1, viewportFraction: 0.85);
  return SizedBox(
    height: 240,
    child: PageView.builder(
      controller: controller,
      itemCount: banners.length,
      itemBuilder: (context, index) {
        final banner = banners[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              banner.url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.error),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        );
      },
    ),
  );
}

Widget buildCategoryHeader(
  BuildContext context,
  String title,
  VoidCallback onSeeAllPressed,
) {
  final screenWidth = MediaQuery.of(context).size.width;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.bold,
        ),
      ),
      GestureDetector(
        onTap: onSeeAllPressed,
        child: Text(
          'See All',
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

Widget buildProductGrid(List<CategoryProduct> products) {
  final displayProducts = products.take(8).toList();
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: displayProducts.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.55,
    ),
    padding: const EdgeInsets.all(14),
    itemBuilder: (context, index) {
      final product = displayProducts[index];
      return GestureDetector(
        onTap: () async {
          final productDetail = await fetchProductDetail(product.productId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetails(details: productDetail),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 75,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              product.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    },
  );
}

Widget showTrendingProduct(Future<List<Product>> trendingProducts) {
  return FutureBuilder<List<Product>>(
    future: trendingProducts,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No trending products available'));
      }

      final products = snapshot.data!;
      final screenWidth = MediaQuery.of(context).size.width;
      final imageHeight = screenWidth * 0.25;
      final fontSize = screenWidth * 0.035;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, CustomColors.baseContainer],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: buildCategoryHeader(context, 'Trending Offers', () {}),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(products.length, (index) {
                  final product = products[index];
                  final option = product.options.first;

                  return Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: GestureDetector(
                      onTap: () async {
                        final productDetail = await fetchProductDetail(
                          product.id,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetails(details: productDetail),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: screenWidth * 0.025),
                        width: screenWidth * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: CustomColors.baseContainer,
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                width: screenWidth,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.network(
                                    product.thumbnail,
                                    height: imageHeight,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenWidth * 0.02),
                            Text(
                              product.title,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenWidth * 0.01),
                            Text(
                              option.unit,
                              style: TextStyle(
                                fontSize: fontSize * 0.9,
                                color: Colors.grey[700],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rs.${option.offerPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: CustomColors.baseColor,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Add',
                                      style: TextStyle(
                                        fontSize: fontSize * 0.9,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    },
  );
}
