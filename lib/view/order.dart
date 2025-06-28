import 'package:flutter/material.dart';
import 'package:pakket/model/order.dart';
import 'package:pakket/controller/orderdetails.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/widget/ordermodal.dart';

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
                                _showOrderDetailModal(order.orderId),
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

  void _showOrderDetailModal(String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => OrderDetailModal(orderId: orderId),
    );
  }
}
