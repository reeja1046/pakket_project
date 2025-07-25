import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pakket/controller/address.dart';
import 'package:pakket/controller/cart.dart';
import 'package:pakket/controller/orderplaced.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/getxcontroller/bottomnavbar_controller.dart';
import 'package:pakket/getxcontroller/home_ad_controller.dart';
import 'package:pakket/model/address.dart';
import 'package:pakket/model/cartfetching.dart';
import 'package:pakket/model/orderplaced.dart';
import 'package:pakket/view/checkout/widgets/address.dart';
import 'package:pakket/view/checkout/widgets/beforecheckout.dart';
import 'package:pakket/view/checkout/widgets/widget.dart';
import 'package:pakket/view/widget/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  final bool fromBottomNav;

  const CheckoutPage({super.key, this.fromBottomNav = false});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<CartItemModelFetching> cartItems = [];
  bool isLoading = true;
  int deliveryCharge = 0; // Initially 0
  bool isDeliveryLoading = false;
  final HomeAdController adController = Get.put(HomeAdController());

  Address? selectedAddress;

  @override
  void initState() {
    super.initState();
    loadCartItems();
    initializeSelectedAddress();
  }

  Future<void> loadCartItems() async {
    print("loadCartItems triggered");
    final items = await getCart();
    setState(() {
      cartItems = mergeCartItems(items);
      isLoading = false;
    });
  }

  Future<void> initializeSelectedAddress() async {
    List<Address> addresses = await fetchAddresses();

    if (addresses.isNotEmpty) {
      setState(() {
        selectedAddress = addresses.first; // Last added address
      });
      fetchDeliveryCharge(selectedAddress!.id);
    }
  }

  List<CartItemModelFetching> mergeCartItems(
    List<CartItemModelFetching> items,
  ) {
    final Map<String, CartItemModelFetching> groupedItems = {};

    for (var item in items) {
      final key = '${item.productId}_${item.optionId}';

      if (groupedItems.containsKey(key)) {
        groupedItems[key]!.quantity += item.quantity;
      } else {
        groupedItems[key] = CartItemModelFetching(
          itemId: item.itemId,
          productId: item.productId,
          title: item.title,
          imageUrl: item.imageUrl,
          unit: item.unit,
          basePrice: item.basePrice,
          offerPrice: item.offerPrice,
          inStock: item.inStock,
          quantity: item.quantity,
          optionId: item.optionId,
        );
      }
    }

    return groupedItems.values.toList();
  }

  Future<void> fetchDeliveryCharge(String addressId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      setState(() => isDeliveryLoading = true);
      final url =
          'https://pakket-dev.vercel.app/api/app/delivery/charge?addressId=$addressId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          deliveryCharge = (data['charge'] as num).toInt();
          isDeliveryLoading = false;
        });
      } else {
        throw Exception('Failed to fetch delivery charge');
      }
    } catch (e) {
      setState(() => isDeliveryLoading = false);
      showSuccessSnackbar(context, 'Failed to fetch delivery charge');
    }
  }

  int get itemTotal => cartItems.fold(
    0,
    (sum, item) =>
        sum + ((item.offerPrice ?? 0) * (item.quantity ?? 0)).toInt(),
  );

  int get grandTotal => itemTotal + deliveryCharge;

  void _showChangeAddressModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddressModal(
        onAddressSelected: (address) {
          setState(() => selectedAddress = address);
          fetchDeliveryCharge(address.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.scaffoldBgClr,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Checkout"),
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
        backgroundColor: CustomColors.scaffoldBgClr,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.withOpacity(0.3), // Border color
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : cartItems.isEmpty
            ? const Center(child: Text("No items in cart."))
            : CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: cartItems.length,
                      (context, index) =>
                          buildCartItem(cartItems[index], index),
                    ),
                  ),
                  CheckoutDealsSection(
                    onProductAdded: () {
                      loadCartItems(); // reload cart instantly when something is added
                    },
                  ),
                  SliverToBoxAdapter(
                    child: Obx(() {
                      final banner = adController.checkoutbanner.value;

                      if (banner == null) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              'Sponsored Advertisement',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 6),
                            InkWell(
                              onTap: () {
                                if (banner.redirectUrl.isNotEmpty) {
                                  launchUrl(Uri.parse(banner.redirectUrl));
                                }
                              },
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 200,
                                    child: Image.network(
                                      banner.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  SliverToBoxAdapter(child: _buildPriceAndPlaceOrderSection()),
                ],
              ),
      ),
    );
  }

  Widget buildCartItem(CartItemModelFetching item, int index) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
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
                child: Image.network(item.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Text and Price Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.unit,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    buildQuantityControl(item, index),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs.${item.offerPrice.toInt()}/-',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rs. ${(item.offerPrice * item.quantity).toInt()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuantityControl(CartItemModelFetching item, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Quantity Box
        Container(
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: CustomColors.baseContainer),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minus Button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.remove, size: 18),
                onPressed: () async {
                  if (item.quantity > 1) {
                    bool isUpdated = await updateCartItemQuantity(
                      item.itemId,
                      'dec',
                      context,
                    );
                    if (isUpdated) {
                      setState(() => cartItems[index].quantity--);
                    }
                  } else {
                    bool isDeleted = await deleteCartItem(item.itemId, context);
                    if (isDeleted) loadCartItems();
                  }
                },
              ),

              // Quantity Count
              Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Plus Button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.add, size: 18),
                onPressed: () async {
                  bool isUpdated = await updateCartItemQuantity(
                    item.itemId,
                    'inc',
                    context,
                  );
                  if (isUpdated) {
                    setState(() => cartItems[index].quantity++);
                  }
                },
              ),
            ],
          ),
        ),
      ],
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
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 10),
          priceRow("Item total", "Rs. $itemTotal"),
          const SizedBox(height: 10),
          priceRow(
            "Delivery charges",
            isDeliveryLoading ? "Loading..." : "Rs. $deliveryCharge",
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          priceRow("Grand Total", "Rs. $grandTotal", bold: true),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Delivering Address:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: _showChangeAddressModal,
                child: Text(
                  selectedAddress == null ? "Add" : "Change",
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
            selectedAddress == null
                ? "No address selected"
                : '${selectedAddress!.address}, ${selectedAddress!.locality}',
          ),
          const SizedBox(height: 40),
          buildPlaceOrderButton(),
        ],
      ),
    );
  }

  Widget buildPlaceOrderButton() {
    return Row(
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
            onPressed: () async {
              if (selectedAddress == null) {
                showSuccessSnackbar(
                  context,
                  "Please select an address before placing order",
                );
                return;
              }

              final orderItems = cartItems
                  .map(
                    (item) => OrderItem(
                      deliveryCharge: deliveryCharge,
                      item: item.productId,
                      option: item.optionId,
                      quantity: item.quantity,
                      priceAtOrder: item.offerPrice,
                    ),
                  )
                  .toList();

              final orderRequest = OrderRequest(
                deliveryCharge: deliveryCharge,
                address: selectedAddress!.id,
                items: orderItems,
              );

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
              final response = await placeOrder(orderRequest, context);

              Navigator.pop(context);

              if (response != null) showBlurDialog(context);
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
    );
  }
}
