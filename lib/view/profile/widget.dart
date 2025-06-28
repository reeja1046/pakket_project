import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pakket/controller/address.dart';
import 'package:pakket/model/order.dart';
import 'package:pakket/controller/orderdetails.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/address.dart';
import 'package:pakket/view/checkout/widgets/address.dart';
import 'package:pakket/view/checkout/widgets/widget.dart';
import 'package:pakket/view/widget/ordermodal.dart';
import 'package:pakket/view/widget/snackbar.dart';

class HelpCenterList extends StatefulWidget {
  const HelpCenterList({super.key});

  @override
  State<HelpCenterList> createState() => _HelpCenterListState();
}

class _HelpCenterListState extends State<HelpCenterList> {
  final List<bool> _isExpandedList = [false, false, false, false];
  int selectedAddressIndex = 0; // Default selected address is the first one
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

      // Set the first address as selected by default
      if (savedAddresses.isNotEmpty && selectedAddressIndex == null) {
        selectedAddressIndex = 0;
      }
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return AddressModal(
            onAddressSelected: (address) async {
              setState(() {
                selectedAddress = address;
              });
              await fetchAddressList();
            },
          );
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
      builder: (context) => OrderDetailModal(orderId: orderId),
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
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
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
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
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
                    ],
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
                                activeColor: CustomColors.baseColor,
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${savedAddresses[i].address}, ${savedAddresses[i].locality}',
                                        style: TextStyle(
                                          fontWeight: selectedAddressIndex == i
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: selectedAddressIndex == i
                                              ? Colors.black
                                              : Colors.black54,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        final confirmed = await showBlurDialog(
                                          context: context,
                                          title: 'Delete Address',
                                          description:
                                              'Are you sure you want to delete this address?',
                                          actionText: 'Delete',
                                          icon: Icons.delete,
                                        );

                                        if (confirmed == true) {
                                          final isDeleted =
                                              await deleteAddressApi(
                                                savedAddresses[i].id,
                                              );

                                          if (isDeleted) {
                                            setState(() {
                                              savedAddresses.removeAt(i);
                                              if (selectedAddressIndex == i) {
                                                selectedAddressIndex = -1;
                                              } else if (selectedAddressIndex >
                                                  i) {
                                                selectedAddressIndex -= 1;
                                              }
                                            });
                                            showSuccessSnackbar(
                                              context,
                                              'Address deleted successfully',
                                            );
                                          } else {
                                            showSuccessSnackbar(
                                              context,
                                              'Failed to delete address',
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                value: i,
                                groupValue: selectedAddressIndex,
                                onChanged: (val) {
                                  setState(() {
                                    selectedAddressIndex = val!;
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
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: CustomColors.baseColor,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                    'Reach us at help@pakket.com.',
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

  Future<bool?> showBlurDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String actionText,
    required IconData icon,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, _, __) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CustomColors.baseColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 30, color: CustomColors.baseColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          actionText,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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
      },
    );
  }
}
