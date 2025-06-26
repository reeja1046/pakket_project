import 'package:flutter/material.dart';
import 'package:pakket/model/order.dart';
import 'package:pakket/controller/orderdetails.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/orderfetch.dart';

class OrderDetailModal extends StatelessWidget {
  final String orderId;

  const OrderDetailModal({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
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
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
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
                            icon: const Icon(Icons.close, size: 14),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Order No: ${order.orderId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${order.createdAt}',
                      style: TextStyle(color: CustomColors.baseColor),
                    ),
                    const SizedBox(height: 8),
                    const Text('Delivered at:'),
                    Text(
                      '${order.address.address}, ${order.address.locality}, Floor: ${order.address.floor ?? 'N/A'}, Landmark: ${order.address.landmark ?? 'N/A'}',
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
            style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
          Text(
            value,
            style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }
}
