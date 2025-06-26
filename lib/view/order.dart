import 'package:flutter/material.dart';
import 'package:pakket/model/order.dart';
import 'package:pakket/controller/orderdetails.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/orderfetch.dart';

class OrderScreen extends StatefulWidget {
  final bool fromBottomNav;
  final VoidCallback? onBack;

  const OrderScreen({super.key, this.fromBottomNav = false, this.onBack});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.scaffoldBgClr,
      appBar: AppBar(
        backgroundColor: CustomColors.scaffoldBgClr,
        centerTitle: true,
        title: Text(
          'Your Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
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
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Container(
                height: 40,
                width: double.infinity,
                color: CustomColors.baseColor,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Your orders list',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<Order>>(
                  future: fetchOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No orders found."));
                    }

                    final orders = snapshot.data!;
                    return ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return ListTile(
                          title: Text('Order Number: ${order.orderId}'),
                          subtitle: Text(
                            'Status: ${order.status}',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: TextButton(
                            onPressed: () =>
                                _showOrderDetails(context, order.orderId),
                            child: Text(
                              'View in details',
                              style: TextStyle(color: CustomColors.baseColor),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, String orderId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<OrderDetail>(
          future: fetchOrderDetail(orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              final order = snapshot.data!;
              print(order);
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: CustomColors.baseColor,
                            child: IconButton(
                              icon: Icon(Icons.close, size: 14),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Order No: ${order.orderId}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${order.createdAt}',
                        style: TextStyle(color: CustomColors.baseColor),
                      ),
                      const SizedBox(height: 8),
                      Text('Delivered at:'),
                      Text(
                        '${order.address.address}, ${order.address.locality}, Floor: ${order.address.floor}, Landmark: ${order.address.landmark}',
                      ),
                      const Divider(height: 30),

                      ...order.items.map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Image.network(
                                item.thumbnail,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title),
                                    Text('${item.unit} x ${item.quantity}'),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${(item.priceAtOrder * item.quantity).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _priceRow(
                              'Item total',
                              '₹${order.totalPrice.toStringAsFixed(2)}',
                            ),
                            _priceRow(
                              'Delivery charge',
                              '₹${order.deliveryCharge.toStringAsFixed(2)}',
                            ),
                            const Divider(),
                            _priceRow(
                              'Total',
                              '₹${(order.totalPrice + order.deliveryCharge).toStringAsFixed(2)}',
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null,
          ),
          Text(
            value,
            style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }
}
