import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakket/controller/cart.dart';
import 'package:pakket/controller/orderplaced.dart';
import 'package:pakket/controller/trending.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/cart.dart';
import 'package:pakket/model/orderplaced.dart';
import 'package:pakket/model/trending.dart';
import 'package:pakket/view/checkout/widget.dart';
import 'package:pakket/view/order.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<CartItemModel> cartItems = [];
  bool isLoading = true;
  String _selectedAddress = "default";
  List<int> quantities = [];
  late Future<List<Product>> _futureTrendingProducts;
  @override
  void initState() {
    super.initState();
    loadCartItems();
    _futureTrendingProducts = fetchTrendingProducts();
  }

  Future<void> loadCartItems() async {
    final items = await getCart();
    setState(() {
      quantities = items.map((e) => e.quantity).toList();
      cartItems = items;
      isLoading = false;
    });
  }

  int get itemTotal => cartItems.fold(
    0,
    (sum, item) => sum + (item.offerPrice * item.quantity).toInt(),
  );

  int get deliveryCharge => 50;
  int get grandTotal => itemTotal + deliveryCharge;

  void _showChangeAddressModal() {
    TextEditingController addressController = TextEditingController();
    bool showAddressField = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select An Address",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: CustomColors.baseColor,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RadioListTile(
                    value: "address1",
                    groupValue: _selectedAddress,
                    activeColor: Colors.orange,
                    onChanged: (val) {
                      setState(() => _selectedAddress = val.toString());
                      Navigator.pop(context);
                    },
                    title: const Text(
                      "John Doe, 123 Street, Kochi, Kerala - 682001",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  RadioListTile(
                    value: "address2",
                    groupValue: _selectedAddress,
                    activeColor: Colors.orange,
                    onChanged: (val) {
                      setState(() => _selectedAddress = val.toString());
                      Navigator.pop(context);
                    },
                    title: const Text(
                      "Jane Smith, 456 Road, Calicut, Kerala - 673001",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setModalState(() => showAddressField = true);
                    },
                    child: const Text("+ Add New Address"),
                  ),
                  if (showAddressField) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Enter your address",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (addressController.text.trim().isNotEmpty) {
                          setState(
                            () => _selectedAddress = addressController.text
                                .trim(),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Save Address"),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.scaffoldBgClr,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Address selection & change",
          style: TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.scaffoldBgClr,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(child: Text("No items in cart."))
          : CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: cartItems.length,
                    (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        padding: const EdgeInsets.all(12),

                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              color: CustomColors.textformfield,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: CustomColors.baseContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.network(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.unit,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rs.${item.offerPrice.toInt()}/-',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: CustomColors.baseContainer,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: () {
                                      setState(() {
                                        if (quantities[index] > 1) {
                                          quantities[index]--;
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    '${quantities[index]}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () {
                                      setState(() {
                                        quantities[index]++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        const Text(
                          "Before you checkout",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.28,
                          child: FutureBuilder<List<Product>>(
                            future: _futureTrendingProducts,
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
                                  child: Text('No deals found.'),
                                );
                              }

                              final products = snapshot.data!;

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(products.length.clamp(0, 2), (
                                  index,
                                ) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: List.generate(products.length, (
                                        index,
                                      ) {
                                        final product = products[index];
                                        final option = product.options.first;

                                        double screenWidth = MediaQuery.of(
                                          context,
                                        ).size.width;
                                        double cardWidth = screenWidth * 0.45;
                                        double imageHeight = screenWidth * 0.25;
                                        double fontSize = screenWidth * 0.035;

                                        return Container(
                                          margin: EdgeInsets.only(
                                            right: screenWidth * 0.025,
                                          ),
                                          width: cardWidth,
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.white,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                  screenWidth * 0.03,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      child: Container(
                                                        color: CustomColors
                                                            .baseContainer,
                                                        height:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.height *
                                                            0.15,
                                                        width: screenWidth,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                5.0,
                                                              ),
                                                          child: Image.network(
                                                            product.thumbnail,
                                                            height: imageHeight,
                                                            width:
                                                                double.infinity,
                                                            fit: BoxFit.contain,
                                                            errorBuilder:
                                                                (
                                                                  _,
                                                                  __,
                                                                  ___,
                                                                ) => const Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          screenWidth * 0.02,
                                                    ),
                                                    Text(
                                                      product.title,
                                                      style: TextStyle(
                                                        fontSize: fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          screenWidth * 0.01,
                                                    ),
                                                    Text(
                                                      option.unit,
                                                      style: TextStyle(
                                                        fontSize:
                                                            fontSize * 0.9,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Rs.${option.offerPrice.floor()}',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Rs.${option.basePrice.floor()}',
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            decorationColor:
                                                                Colors.black,
                                                            decorationThickness:
                                                                2,
                                                          ),
                                                        ),

                                                        Container(
                                                          width: 60,
                                                          height: 30,
                                                          decoration: BoxDecoration(
                                                            color: CustomColors
                                                                .baseColor,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  7,
                                                                ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              'Add',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    fontSize *
                                                                    0.9,
                                                                color: Colors
                                                                    .white,
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
                                          ),
                                        );
                                      }),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildPriceAndPlaceOrderSection()),
              ],
            ),
    );
  }

  Widget _buildPriceAndPlaceOrderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Price Details",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          const Divider(),
          SizedBox(height: 10),
          priceRow("Item total", "Rs. $itemTotal"),
          SizedBox(height: 10),
          priceRow("Delivery charges", "Rs. $deliveryCharge"),
          SizedBox(height: 10),
          const Divider(),
          SizedBox(height: 10),
          priceRow("Grand Total", "Rs. $grandTotal", bold: true),
          SizedBox(height: 10),
          const Divider(),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Delivering Address:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: _showChangeAddressModal,
                child: const Text(
                  "Change",
                  style: TextStyle(
                    color: CustomColors.baseColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _selectedAddress == "default"
                ? "John Doe, 123 Street, Kochi, Kerala - 682001"
                : _selectedAddress,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "Paying using\n"),
                    TextSpan(
                      text: "Google Pay",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final orderItems = cartItems.map((item) {
                      return OrderItem(
                        item: item.itemId, // From CartItemModel
                        option: item.optionId, // From CartItemModel
                        quantity: item.quantity,
                        priceAtOrder: item.offerPrice,
                      );
                    }).toList();

                    final order = OrderRequest(
                      address:
                          "67ea5ae71093b683607214be", // Replace this with actual selected address ID
                      items: orderItems,
                    );

                    placeOrder(order, context);

                    showBlurDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.baseColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Rs. $grandTotal",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const VerticalDivider(
                          color: Colors.white,
                          width: 2,
                          thickness: 2,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Place Order",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
