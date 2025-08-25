import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakket/controller/product.dart';
import 'package:pakket/controller/trending.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/product.dart';
import 'package:pakket/model/trending.dart';
import 'package:pakket/view/product/widget.dart';
import 'package:pakket/view/widget/modal.dart';

class ProductDetails extends StatefulWidget {
  final String productId;
  const ProductDetails({super.key, required this.productId});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool showMore = false;
  List<int> quantities = [];

  late Future<ProductDetail?> _productDetailFuture;
  late Future<List<Product>> _futureTrendingProducts;

  @override
  void initState() {
    super.initState();
    _futureTrendingProducts = fetchTrendingProducts();
    _productDetailFuture = fetchProductDetail(widget.productId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int getTotalQuantity(List<int> quantities) {
    return quantities.fold(0, (sum, qty) => sum + qty);
  }

  double getTotalAmount(List<int> quantities, ProductDetail product) {
    double total = 0.0;
    for (int i = 0; i < product.options.length; i++) {
      total += quantities[i] * product.options[i].offerPrice;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.scaffoldBgClr,
      appBar: buildAppBar(context),
      body: SafeArea(
        child: FutureBuilder<ProductDetail?>(
          future: _productDetailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Product not found.'));
            }

            final product = snapshot.data!;

            // Initialize quantities after product is fetched
            if (quantities.isEmpty) {
              quantities = List.filled(product.options.length, 0);
            }

            return Stack(children: [_buildProductDetails(context, product)]);
          },
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, ProductDetail product) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(product),
            const SizedBox(height: 20),
            _buildProductTitle(product),
            const SizedBox(height: 8),
            _buildProductDescription(product),
            const SizedBox(height: 25),
            _buildPriceAndOption(product),
            const SizedBox(height: 25),
            _buildBestDealHeader(),
            const SizedBox(height: 12),
            buildBestDealItems(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(ProductDetail product) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _pageController,
              itemCount: product.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  product.images[index],
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              product.images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 8 : 8,
                height: _currentPage == index ? 8 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? CustomColors.baseColor
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTitle(ProductDetail product) {
    return Text(
      product.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildBestDealHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Trending Products',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildBestDealItems() {
    return FutureBuilder<List<Product>>(
      future: _futureTrendingProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No deals found.'));
        }

        final products = snapshot.data!;

        return OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;
            final size = MediaQuery.of(context).size;
            final shortestSide = size.shortestSide;
            final screenWidth = size.width;

            /// Make card width smaller in landscape
            final cardWidth = isPortrait
                ? screenWidth * 0.4
                : screenWidth * 0.22;

            /// Image height proportional to card width
            final imageHeight = isPortrait ? cardWidth * 0.6 : cardWidth * 0.4;

            /// Keep font size same as before (no change)
            final fontSize = shortestSide * 0.035;

            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              // padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(products.length, (index) {
                        final product = products[index];
                        final option = product.options.first;

                        return GestureDetector(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetails(productId: product.id),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              right: isPortrait
                                  ? screenWidth * 0.025
                                  : screenWidth * 0.015,
                            ),
                            width: cardWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.all(cardWidth * 0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    color: CustomColors.baseContainer,
                                    height: imageHeight,
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Image.network(
                                        product.thumbnail,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: shortestSide * 0.02),
                                Text(
                                  product.title,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: shortestSide * 0.01),
                                Text(
                                  option.unit,
                                  style: TextStyle(
                                    fontSize: fontSize * 0.8,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rs.${option.offerPrice.floor()}',
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                      width: isPortrait ? 80 : 65,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor:
                                              CustomColors.baseColor,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final productDetail =
                                              await fetchProductDetail(
                                                product.id,
                                              );
                                          showProductOptionBottomSheet(
                                            context: context,
                                            product: productDetail!,
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
                              ],
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
      },
    );
  }

  Widget _buildProductDescription(ProductDetail product) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black,
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: showMore
                ? product.description
                : product.description.length > 100
                ? '${product.description.substring(0, 100)}... '
                : product.description,
          ),
          TextSpan(
            text: showMore ? 'Show Less' : 'More',
            style: const TextStyle(color: Colors.orange),
            recognizer: TapGestureRecognizer()
              ..onTap = () => setState(() => showMore = !showMore),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndOption(ProductDetail product) {
    final firstOption = product.options.first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Rs.${firstOption.offerPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            Text(
              'Rs.${firstOption.basePrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.black,
                decorationThickness: 2,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            showProductOptionBottomSheet(context: context, product: product);
          },
          child: Container(
            height: 30,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: CustomColors.baseColor,
            ),
            child: Container(
              height: 30,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: CustomColors.baseColor,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${product.options.length} options',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Transform.rotate(
                        angle: 1.57,
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
