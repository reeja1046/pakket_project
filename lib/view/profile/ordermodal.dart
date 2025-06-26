import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                    SizedBox(height: 20),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order details',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: CustomColors.baseColor,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Order No: ${order.orderId}'),
                    const SizedBox(height: 8),
                    Text(
                      formatServerDateTime('${order.createdAt}'),
                      style: TextStyle(color: CustomColors.baseColor),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    const Text('Delivered at:'),
                    SizedBox(height: 5),
                    Text(
                      '${order.address.address}, ${order.address.locality}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 30),

                    ...order.items.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image with background color
                            Container(
                              decoration: BoxDecoration(
                                color: Colors
                                    .grey
                                    .shade200, // Background only for image
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Image.network(
                                item.thumbnail,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Quantity: ${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rs.${item.priceAtOrder.toStringAsFixed(2)} x ${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Total price
                            Text(
                              'Rs.${(item.priceAtOrder * item.quantity).floor()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          Text(
                            'Amount Details',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          _priceRow(
                            'Item total',
                            'Rs.${order.totalPrice.toStringAsFixed(2)}',
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          _priceRow(
                            'Delivery charge',
                            'Rs.${order.deliveryCharge.toStringAsFixed(2)} ',
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          const Divider(),
                          _priceRow(
                            'Total',
                            'Rs.${(order.totalPrice + order.deliveryCharge).toStringAsFixed(2)}',
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

  String formatServerDateTime(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString); // Keep it in UTC
    final String formattedDate = DateFormat(
      'hh:mm a  dd MMMM yyyy',
    ).format(dateTime);
    return formattedDate;
  }
}
