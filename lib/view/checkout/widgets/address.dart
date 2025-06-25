import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakket/controller/map.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/checkout/widgets/widget.dart';
import 'package:pakket/view/order.dart';
import 'package:pakket/controller/address.dart';
import 'package:pakket/model/address.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressModal extends StatefulWidget {
  final Function(Address) onAddressSelected;

  const AddressModal({super.key, required this.onAddressSelected});

  @override
  State<AddressModal> createState() => _AddressModalState();
}

class _AddressModalState extends State<AddressModal> {
  String selectedFor = 'Myself';
  bool showAddressField = false;
  bool isLoading = true;
  List<Address> addressList = [];

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

  //verify location
  void verifyLocation() async {
    print('eeee');
    String mapUrl = googleMapLinkController.text.trim();
    if (mapUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid Google Map link.')),
      );
      return;
    }

    try {
      // Example API call using http package
      var response = await checkLocationServiceability(mapUrl);

      if (response['isDeliverable'] == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(' Deliverable'),
            content: Text('Delivery is  available at this location.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Not Deliverable'),
            content: Text(
              'We are sorry. Delivery is not available at this location.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying location. Please try again.')),
      );
    }
  }

  Future<void> loadAddresses() async {
    final addresses = await fetchAddresses();
    setState(() {
      addressList = addresses;
      isLoading = false;
    });
  }

  void saveAddress() async {
    if (addressController.text.trim().isNotEmpty &&
        localityController.text.trim().isNotEmpty &&
        (selectedFor == 'Someone Else'
            ? googleMapLinkController.text.trim().isNotEmpty
            : true)) {
      String mapLink = '';
      double? latitude;
      double? longitude;

      if (selectedFor == 'Myself') {
        try {
          final prefs = await SharedPreferences.getInstance();
          latitude = await prefs.getDouble('latitude');
          longitude = await prefs.getDouble('longitude');
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to get current location: $e')),
          );
          return; // Stop further execution if location fails
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save address.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.')),
      );
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
                    title: Text(
                      '${address.address}, ${address.locality}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() => showAddressField = true);
              },
              child: const Text("+ Add New Address"),
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
              buildTextField(addressController, "Enter your address"),
              const SizedBox(height: 12),
              buildTextField(localityController, "Enter your locality"),
              const SizedBox(height: 12),
              selectedFor == 'Someone Else'
                  ? Column(
                      children: [
                        Row(
                          children: [
                            // TextField takes available space
                            Expanded(
                              child: buildTextField(
                                googleMapLinkController,
                                "Place your Google map link",
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Spacing between field and button
                            GestureDetector(
                              onTap: () => verifyLocation(),
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(border: Border.all()),
                                child: Text('Verify'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  : const SizedBox(),
              buildTextField(landmarkController, "Landmark (if any)"),
              const SizedBox(height: 12),
              buildTextField(floorController, "Enter your floor (optional)"),
              const SizedBox(height: 12),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: saveAddress,
                child: const Text("Save Address"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
