import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pakket/controller/map.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/controller/address.dart';
import 'package:pakket/model/address.dart';
import 'package:pakket/view/checkout/widgets/widget.dart';
import 'package:pakket/view/widget/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressModal extends StatefulWidget {
  final Function(Address) onAddressSelected;

  const AddressModal({super.key, required this.onAddressSelected});

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

  TextEditingController addressController = TextEditingController();
  TextEditingController localityController = TextEditingController();
  TextEditingController googleMapLinkController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController floorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    final addresses = await fetchAddresses();
    setState(() {
      addressList = addresses;
      isLoading = false;
    });
  }

  void verifyLocation() async {
    String mapUrl = googleMapLinkController.text.trim();
    if (mapUrl.isEmpty) {
      showSuccessSnackbar(context, 'Please enter a valid Google Map link.');
      return;
    }

    try {
      var response = await checkLocationServiceability(mapUrl);

      if (response['isDeliverable'] == true) {
        setState(() {
          isVerified = true; // Set verification flag
        });
        showBlurDialog(
          context,
          'Deliverable',
          'Delivery is available on this location',
        );
      } else {
        setState(() {
          isVerified = false; // Reset if not deliverable
        });

        showBlurDialog(
          context,
          'Not deliverable',
          'Delivery is not available on this location',
        );
      }
    } catch (e) {
      showSuccessSnackbar(
        context,
        'Error verifying location. Please try again.',
      );
    }
  }

  void showBlurDialog(BuildContext context, String text1, String text2) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder:
          (
            BuildContext buildContext,
            Animation animation,
            Animation secondaryAnimation,
          ) {
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pop(context);
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
                ),
              ),
            );
          },
    );
  }

  void saveAddress() async {
    if (_formKey.currentState!.validate()) {
      String mapLink = '';
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
      } else {
        mapLink = googleMapLinkController.text.trim();
      }

      final request = AddressRequest(
        address: addressController.text.trim(),
        locality: localityController.text.trim(),
        googleMapLink: mapLink,
        landmark: landmarkController.text.trim(),
        floor: floorController.text.trim(),
        lattitude: latitude,
        longitude: longitude,
      );

      Address? newAddress = await addAddressApi(request);
      if (newAddress != null) {
        widget.onAddressSelected(newAddress);
        Navigator.pop(context);
      } else {
        print('not deliverable');
        showBlurDialog(
          context,
          'Not deliverable',
          'This postcode is not deliverable!',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  TextFormField(
                    controller: googleMapLinkController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Google map link is required';
                      }
                      if (!isVerified) {
                        return 'Please verify this location before saving.';
                      }
                      return null;
                    },

                    decoration: InputDecoration(
                      hintText: "Place your Google map link",
                      filled: true,
                      fillColor: Colors.white,
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
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: verifyLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.baseColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minHeight: 32,
                        minWidth: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],

                buildTextField(landmarkController, "Landmark (if any)"),
                const SizedBox(height: 12),
                buildTextField(floorController, "Enter your floor (optional)"),
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
    );
  }
}
