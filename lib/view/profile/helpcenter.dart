import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pakket/controller/address.dart';
import 'package:pakket/model/order.dart';
import 'package:pakket/controller/orderdetails.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/address.dart';
import 'package:pakket/view/checkout/widgets/address.dart';
import 'package:pakket/view/profile/widgets.dart';
import 'package:pakket/view/widget/ordermodal.dart';
import 'package:pakket/view/widget/snackbar.dart';

class HelpCenterList extends StatefulWidget {
  const HelpCenterList({super.key});

  @override
  State<HelpCenterList> createState() => _HelpCenterListState();
}

class _HelpCenterListState extends State<HelpCenterList> {
  final List<bool> _isExpandedList = [false, false, false, false, false, false];
  int selectedAddressIndex = 0;
  List<Address> savedAddresses = [];
  bool isLoadingAddresses = true;
  Address? selectedAddress;

  List<Order> orderList = [];
  bool isLoadingOrders = false;

  final List<String> titles = [
    'Current Address details',
    'Your order history',
    'Terms and Conditions',
    'Privacy Policy',
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

        if (index == 2 || index == 3 || index == 4) {
          final url = index == 2
              ? 'https://pakket.in/terms-conditions/'
              : index == 3
              ? 'https://pakket.in/privacy-policy/'
              : 'https://pakket.in/home/';
          return ListTile(
            onTap: () => launchExternalLink(url),
            trailing: CircleAvatar(
              radius: 10,
              backgroundColor: CustomColors.baseColor,
              child: const Icon(
                Icons.keyboard_arrow_right,
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
          );
        }

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
              ] else if (index == 5) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            color: CustomColors.baseColor,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Call Us:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => launchPhone('+918089996656'),
                            child: Text(
                              ' +91 80899 96656',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: CustomColors.baseColor,
                          ),
                          SizedBox(width: 8),
                          Text('Chat with Us:'),
                          GestureDetector(
                            onTap: () => launchWhatsApp('+918089006656'),
                            child: Text(
                              ' +91 80890 06656',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.envelope,
                            color: CustomColors.baseColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('Email:'),
                          GestureDetector(
                            onTap: () =>
                                launchEmail('pakket.allinone@gmail.com'),
                            child: Text(
                              ' pakket.allinone@gmail.com',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
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
