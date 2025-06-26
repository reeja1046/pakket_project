import 'package:flutter/material.dart';
import 'package:pakket/controller/address.dart';
import 'package:pakket/model/order.dart';
import 'package:pakket/controller/orderdetails.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/address.dart';
import 'package:pakket/view/checkout/widgets/address.dart';
import 'package:pakket/view/profile/ordermodal.dart';

class HelpCenterList extends StatefulWidget {
  const HelpCenterList({super.key});

  @override
  State<HelpCenterList> createState() => _HelpCenterListState();
}

class _HelpCenterListState extends State<HelpCenterList> {
  List<bool> _isExpandedList = [false, false, false, false];
  int? selectedAddressIndex;
  List<Address> savedAddresses = [];
  bool isLoadingAddresses = true;
  Address? selectedAddress;

  List<Order> orderList = [];
  bool isLoadingOrders = false;

  final List<String> titles = [
    'Current Address details',
    'Your order history',
    'About us',
    'Contact us',
  ];

  final List<String> responses = [
    'Your saved address for deliveries.',
    'View products you have purchased.',
    'We are a team dedicated to quality.',
    'Reach us at help@pakket.com.',
  ];

  @override
  void initState() {
    super.initState();
    fetchAddressList();
  }

  Future<void> fetchAddressList() async {
    final addresses = await fetchAddresses();
    setState(() {
      savedAddresses = addresses;
      isLoadingAddresses = false;
    });
  }

  Future<void> fetchOrderHistory() async {
    setState(() {
      isLoadingOrders = true;
    });

    try {
      final orders = await fetchOrders();
      setState(() {
        orderList = orders;
      });
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      setState(() {
        isLoadingOrders = false;
      });
    }
  }

  void _showChangeAddressModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddressModal(
        onAddressSelected: (address) async {
          setState(() {
            selectedAddress = address;
          });
          await fetchAddressList();
        },
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
      builder: (context) =>
          OrderDetailModal(orderId: orderId), // Correct widget
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: titles.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final isAddressTile = index == 0;
        final isOrderHistoryTile = index == 1;

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: _isExpandedList[index],
            trailing: isAddressTile
                ? GestureDetector(
                    onTap: _showChangeAddressModal,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: CustomColors.baseColor,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Text(
                          'Add New',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 10,
                    backgroundColor: CustomColors.baseColor,
                    child: Icon(
                      _isExpandedList[index]
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
            title: Text(
              titles[index],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF636260),
                fontWeight: FontWeight.w500,
              ),
            ),
            onExpansionChanged: (expanded) async {
              if (isOrderHistoryTile && expanded && orderList.isEmpty) {
                await fetchOrderHistory();
              }
              setState(() {
                _isExpandedList[index] = expanded;
              });
            },
            children: [
              if (isAddressTile) ...[
                isLoadingAddresses
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : savedAddresses.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No saved addresses found.'),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          children: [
                            for (int i = 0; i < savedAddresses.length; i++)
                              RadioListTile<int>(
                                title: Text(
                                  '${savedAddresses[i].address}, ${savedAddresses[i].locality}',
                                ),
                                value: i,
                                groupValue: selectedAddressIndex,
                                onChanged: (val) {
                                  setState(() {
                                    selectedAddressIndex = val;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
              ] else if (index == 1) ...[
                isLoadingOrders
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : orderList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No orders found.'),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          children: orderList.map((order) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text('Order No: ${order.orderId}'),
                                subtitle: Text('Status: ${order.status}'),
                                trailing: TextButton(
                                  onPressed: () {
                                    _showOrderDetailModal(order.orderId);
                                  },
                                  child: Text(
                                    'View Details',
                                    style: TextStyle(
                                      color: CustomColors.baseColor,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: Text(
                    responses[index],
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
