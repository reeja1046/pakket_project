import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakket/controller/cart.dart';
import 'package:pakket/controller/trending.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/product.dart';
import 'package:pakket/model/trending.dart';
import 'package:pakket/view/checkout/checkout.dart';
import 'package:pakket/view/product/widget.dart';

class ProductDetails extends StatefulWidget {
  final ProductDetail details;
  const ProductDetails({super.key, required this.details});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool showMore = false;
  late List<int> quantities;
  late Future<List<Product>> _futureTrendingProducts;

  @override
  void initState() {
    super.initState();
    _futureTrendingProducts = fetchTrendingProducts();

    quantities = List.filled(
      widget.details.options.length,
      0,
    ); // Default quantity = 1
    print(quantities);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int getTotalQuantity() {
    return quantities.fold(0, (sum, qty) => sum + qty);
  }

  double getTotalAmount() {
    double total = 0.0;
    for (int i = 0; i < widget.details.options.length; i++) {
      total += quantities[i] * widget.details.options[i].offerPrice;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.scaffoldBgClr,
      appBar: buildAppBar(context),
      body: Stack(
        children: [
          _buildProductDetails(context),
          // _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            const SizedBox(height: 20),
            _buildProductTitle(),
            const SizedBox(height: 8),
            _buildProductDescription(),
            const SizedBox(height: 25),
            _buildPriceAndOption(),
            const SizedBox(height: 40),
            _buildBestDealHeader(),
            const SizedBox(height: 12),
            buildBestDealItems(),
            const SizedBox(height: 80), // Extra space for bottom button
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.details.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.details.images[index],
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.details.images.length,
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

  Widget _buildProductTitle() {
    return Text(
      widget.details.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildProductDescription() {
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
                ? widget.details.description
                : widget.details.description.length > 100
                ? '${widget.details.description.substring(0, 100)}... '
                : widget.details.description,
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

  Widget _buildPriceAndOption() {
    final firstOption = widget.details.options.first;

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
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor:
                  Colors.transparent, // Required for gradient to show
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE9ECDB), // 94%
                        Color(0xFFE8EBD5), // 100%
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.94, 1.0],
                    ),
                  ),
                  child: _buildOptionBottomSheet(),
                );
              },
            );
          },
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
                      '${widget.details.options.length} options',
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
      ],
    );
  }

  Widget _buildOptionBottomSheet() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.details.options.length,
                itemBuilder: (context, index) {
                  final option = widget.details.options[index];
                  return ListTile(
                    leading: Image.network(
                      widget
                          .details
                          .thumbnail, // Or use option.image if available
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                    title: Text(widget.details.title, maxLines: 1),
                    subtitle: IntrinsicHeight(
                      child: Row(
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
                            'Rs.${option.offerPrice.floor()}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: quantities[index] == 0
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                quantities[index] = 1;
                              });
                            },
                            child: Container(
                              height: 30,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: CustomColors.baseColor,
                              ),
                              child: const Center(
                                child: Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (quantities[index] > 1) {
                                      quantities[index]--;
                                    } else {
                                      quantities[index] =
                                          0; // Reset to 0 → show "Add"
                                    }
                                  });
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                '${quantities[index]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    quantities[index]++;
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildBottomBar(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBestDealHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Best Deal',
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

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(products.length.clamp(0, 2), (index) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(products.length, (index) {
                  final product = products[index];
                  final option = product.options.first;

                  double screenWidth = MediaQuery.of(context).size.width;
                  double cardWidth = screenWidth * 0.4;
                  double imageHeight = screenWidth * 0.25;
                  double fontSize = screenWidth * 0.035;

                  return Container(
                    margin: EdgeInsets.only(right: screenWidth * 0.025),
                    width: cardWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.03),
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
                                    color: Colors.black,
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
            );
          }),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: CustomColors.baseColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Item total : Rs.${getTotalAmount().toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () async {
                bool anyAdded = false;

                for (int i = 0; i < widget.details.options.length; i++) {
                  final qty = quantities[i];
                  if (qty > 0) {
                    final option = widget.details.options[i];
                    final response = await addToCart(
                      itemId: widget.details.id,
                      optionId: option.id,
                      quantity: qty,
                    );

                    if (response != null && response.success) {
                      anyAdded = true;
                    } else {
                      // Show error if one item fails (optional)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            response?.message ?? 'Failed to add ${option.unit}',
                          ),
                        ),
                      );
                    }
                  }

                  if (anyAdded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart successfully!'),
                      ),
                    );
                    print('suuccess');
                    // Optionally navigate to checkout
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => CheckoutPage()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one option'),
                      ),
                    );
                  }
                }
                ;
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
