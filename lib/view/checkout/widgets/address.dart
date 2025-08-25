import 'dart:ui';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:pakket/controller/pincode.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/controller/address.dart';
import 'package:pakket/model/address.dart';
import 'package:pakket/view/checkout/widgets/widget.dart';
import 'package:pakket/view/widget/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressModal extends StatefulWidget {
  final Address? selectedAddress; // Accept selected address
  final Function(Address) onAddressSelected;

  const AddressModal({
    super.key,
    required this.onAddressSelected,
    this.selectedAddress,
  });

  @override
  State<AddressModal> createState() => _AddressModalState();
}

class _AddressModalState extends State<AddressModal> {
  final _formKey = GlobalKey<FormState>();

  String selectedFor = 'Myself';
  bool showAddressField = false;
  bool isLoading = true;
  List<Address> addressList = [];
  bool isVerified = false;
  Address? currentSelectedAddress;
  bool isLinkEntered = false;

  TextEditingController addressController = TextEditingController();
  TextEditingController localityController = TextEditingController();
  TextEditingController googleMapLinkController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  List<String> availablePincodes = [];
  String? pincode;
  bool isPincodeLoading = true;

  Future<void> fetchPincodes() async {
    try {
      final response = await getPincodes(); // Already returns List<String>
      setState(() {
        availablePincodes = response; // Use directly
        isPincodeLoading = false;
      });
    } catch (e) {
      setState(() {
        isPincodeLoading = false;
      });
      showSuccessSnackbar(context, 'Failed to load pincodes');
    }
  }

  @override
  void initState() {
    currentSelectedAddress =
        widget.selectedAddress; // Initialize selected address
    googleMapLinkController.addListener(() {
      final isNotEmpty = googleMapLinkController.text.trim().isNotEmpty;
      if (isNotEmpty != isLinkEntered) {
        setState(() {
          isLinkEntered = isNotEmpty;
          if (!isNotEmpty) isVerified = false; // reset verification
        });
      }
    });
    loadAddresses();
    fetchPincodes();
    super.initState();
  }

  Future<void> loadAddresses() async {
    final addresses = await fetchAddresses();
    setState(() {
      addressList = addresses;
      isLoading = false;
    });
  }

  void saveAddress() async {
    if (_formKey.currentState!.validate()) {
      double? latitude;
      double? longitude;

      if (selectedFor == 'Myself') {
        try {
          final prefs = await SharedPreferences.getInstance();
          latitude = prefs.getDouble('latitude');
          longitude = prefs.getDouble('longitude');
        } catch (e) {
          showSuccessSnackbar(context, 'Failed to get current location: $e');
          return;
        }
      }

      final request = AddressRequest(
        address: addressController.text.trim(),
        locality: localityController.text.trim(),
        landmark: landmarkController.text.trim(),
        floor: floorController.text.trim(),
        lattitude: latitude,
        pincode: pincode,
        longitude: longitude,
      );

      final result = await addAddressApi(request);

      if (result == null) return; // token expired handled globally

      final bool success = result['success'];
      final Address? newAddress = result['address'];

      if (success && newAddress != null) {
        Navigator.pop(context);
        // Show success blur dialog
        showBlurDialog(context, 'Deliverable', 'Address added successfully!');

        widget.onAddressSelected(newAddress);
      } else {
        Navigator.pop(context);
        // Show failure blur dialog
        showBlurDialog(
          context,
          'Not Deliverable',

          "Sorry, we currently don't deliver to this location. Please try a different address.",
        );
      }
    }
  }

  void showBlurDialog(BuildContext context, String text1, String text2) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54, // Adds dimmed background
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder:
          (
            BuildContext buildContext,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            // Auto close after 4 seconds
            Future.delayed(const Duration(seconds: 4), () {
              if (Navigator.canPop(buildContext)) {
                Navigator.pop(buildContext); // Close blur dialog
              }
            });

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
                      text1 == "Deliverable"
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                ),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: CustomColors.baseColor,
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ],
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                ),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: CustomColors.baseColor,
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 10),
                      Text(
                        text1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        text2,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                  // child: Column(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     text1 == "Deliverable"
                  //         ? const Icon(
                  //             Icons.check_circle,
                  //             color: Colors.white,
                  //             size: 60,
                  //           )
                  //         : const Icon(
                  //             Icons.error,
                  //             color: Colors.white,
                  //             size: 60,
                  //           ),
                  //     const SizedBox(height: 10),
                  //     Text(
                  //       text1,
                  //       textAlign: TextAlign.center,
                  //       style: const TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     const SizedBox(height: 10),
                  //     Text(
                  //       text2,
                  //       textAlign: TextAlign.center,
                  //       style: const TextStyle(color: Colors.black),
                  //     ),
                  //     const SizedBox(height: 40),
                  //   ],
                  // ),
                ),
              ),
            );
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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

                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (addressList.isEmpty)
                  const Text('No addresses found.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: addressList.length,
                    itemBuilder: (context, index) {
                      final address = addressList[index];

                      return RadioListTile<Address>(
                        value: address,
                        groupValue: null,
                        activeColor: Colors.orange,
                        onChanged: (val) {
                          if (val != null) {
                            widget.onAddressSelected(val);
                            Navigator.pop(context);
                          }
                        },
                        title: Text('${address.address}, ${address.locality}'),
                      );
                    },
                  ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.baseColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation:
                        0, // Optional: to make it look flat like your container
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 14,
                    ),
                  ),
                  onPressed: () {
                    setState(() => showAddressField = true);
                  },
                  child: const Text(
                    "+ Add new address",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),

                if (showAddressField) ...[
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Myself',
                            groupValue: selectedFor,
                            activeColor: CustomColors.baseColor,
                            onChanged: (value) {
                              setState(() {
                                selectedFor = value!;
                              });
                            },
                          ),
                          const Text('Myself'),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Someone Else',
                            groupValue: selectedFor,
                            activeColor: CustomColors.baseColor,
                            onChanged: (value) {
                              setState(() {
                                selectedFor = value!;
                              });
                            },
                          ),
                          const Text('Someone Else'),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  buildTextField(
                    addressController,
                    "Enter your address",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  buildTextField(
                    floorController,
                    "Enter your floor",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'floor is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  buildTextField(
                    localityController,
                    "Enter your locality",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Locality is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  if (selectedFor == 'Someone Else') ...[
                    isPincodeLoading
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField2<String>(
                            isExpanded: true,
                            value: pincode,
                            items: availablePincodes
                                .map(
                                  (pincode) => DropdownMenuItem<String>(
                                    value: pincode,
                                    child: Text(
                                      pincode,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                pincode = value;
                              });
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? 'Pincode is required'
                                : null,
                            decoration: InputDecoration(
                              labelText: "Pincode",
                              labelStyle: const TextStyle(fontSize: 14),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: CustomColors.baseColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: CustomColors.baseColor,
                                  width: 2.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: CustomColors.baseColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              width: 200,
                              offset: const Offset(100, 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 42,
                              padding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),

                    const SizedBox(height: 12),
                  ],

                  buildTextField(
                    landmarkController,
                    "Landmark",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'landmark is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.baseColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation:
                          0, // Optional: to make it look flat like your container
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 14,
                      ),
                    ),
                    onPressed: saveAddress,
                    child: const Text("Save Address"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
