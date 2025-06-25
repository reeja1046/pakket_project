import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pakket/controller/cart.dart';
import 'package:pakket/controller/orderplaced.dart';
import 'package:pakket/controller/trending.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/address.dart';
import 'package:pakket/model/cartfetching.dart';
import 'package:pakket/model/orderplaced.dart';
import 'package:pakket/model/trending.dart';
import 'package:pakket/view/checkout/widgets/widget.dart';
import 'package:pakket/view/checkout/widgets/address.dart';
import 'package:pakket/view/checkout/widgets/beforecheckout.dart';
import 'package:pakket/view/order.dart';

class CheckoutPage extends StatefulWidget {
  final bool fromBottomNav;
  final VoidCallback? onBack;

  const CheckoutPage({super.key, this.fromBottomNav = false, this.onBack});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedFor = 'Myself';
  List<CartItemModelFetching> cartItems = [];
  bool isLoading = true;
  Address? _selectedAddress;
  List<int> quantities = [];

  @override
  void initState() {
    super.initState();
    loadCartItems();
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

  Future<void> loadCartItems() async {
    final items = await getCart();
    setState(() {
      quantities = items.map((e) => e.quantity).toList();

      cartItems = mergeCartItems(items);
      ;
      isLoading = false;
    });
  }

  int get itemTotal => cartItems.fold(
    0,
    (sum, item) => sum + (item.offerPrice * item.quantity).toInt(),
  );

  int get deliveryCharge => 50;
  int get grandTotal => itemTotal + deliveryCharge;

  //for address section
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
          setState(() => _selectedAddress = address);
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
        title: const Text(
          "Address selection & change",
          style: TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (widget.fromBottomNav) {
              // If opened from bottom nav, switch tabs
              if (widget.onBack != null) {
                widget.onBack!();
              }
            } else {
              // If opened from product flow, pop the navigation stack
              Navigator.pop(context);
            }
          },
        ),
        backgroundColor: CustomColors.scaffoldBgClr,
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
                                      onPressed: () async {
                                        if (cartItems[index].quantity > 1) {
                                          // Update quantity using PATCH
                                          bool isUpdated =
                                              await updateCartItemQuantity(
                                                cartItems[index].itemId,
                                                'dec',
                                                context,
                                              );

                                          if (isUpdated) {
                                            setState(() {
                                              cartItems[index].quantity--;
                                            });
                                          }
                                        } else {
                                          // Quantity is 1 → Delete the item
                                          bool isDeleted = await deleteCartItem(
                                            cartItems[index].itemId,
                                            context,
                                          );

                                          if (isDeleted) {
                                            loadCartItems(); // Reload updated cart
                                          }
                                        }
                                      },
                                    ),

                                    Text(
                                      '${cartItems[index].quantity}',
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
                                      onPressed: () async {
                                        bool isUpdated =
                                            await updateCartItemQuantity(
                                              cartItems[index].itemId,
                                              'inc',
                                              context,
                                            );

                                        if (isUpdated) {
                                          setState(() {
                                            cartItems[index].quantity++;
                                          });
                                        }
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
                  CheckoutDealsSection(),
                  SliverToBoxAdapter(child: _buildPriceAndPlaceOrderSection()),
                ],
              ),
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
            _selectedAddress == null
                ? "Select an address"
                : '${_selectedAddress!.address}, ${_selectedAddress!.locality}',
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
                  onPressed: () async {
                    print('selected place order');

                    final orderItems = cartItems.map((item) {
                      print(item.productId);
                      return OrderItem(
                        item: item.productId,
                        option: item.optionId,
                        quantity: item.quantity,
                        priceAtOrder: item.offerPrice,
                      );
                    }).toList();
                    print(_selectedAddress!.id);
                    print('pass orderreq to orderreq class');
                    print(orderItems);
                    print(_selectedAddress!.id);
                    final orderRequest = OrderRequest(
                      address: _selectedAddress!
                          .id, // Replace with selected address ID
                      items: orderItems,
                    );

                    print(
                      'Order Items: ${jsonEncode(orderItems.map((e) => e.toJson()).toList())}',
                    );
                    print(
                      'Order Request: ${jsonEncode(orderRequest.toJson())}',
                    );

                    print('comes from order');

                    // ✅ Show loading dialog first
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );
                    print('api call');
                    // ✅ Then call API
                    final response = await placeOrder(orderRequest, context);

                    // ✅ Remove loading dialog
                    Navigator.pop(context);

                    if (response != null) {
                      print('not null');
                      // Show success dialog
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Order Placed Successfully'),
                          content: Text('Order ID: ${response.orderId}'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderScreen(),
                                  ),
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Error is already handled in the controller's Snackbar
                    }
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
