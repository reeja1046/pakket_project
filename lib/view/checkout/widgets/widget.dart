import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/getxcontroller/bottomnavbar_controller.dart';
import 'package:pakket/view/widget/bottomnavbar.dart';

Widget priceRow(String label, String value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

void showBlurDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Order Placed",
    pageBuilder: (_, __, ___) {
      Future.delayed(const Duration(seconds: 2), () {
        Get.find<BottomNavController>().changeIndex(0);
        Navigator.pop(context);
        Get.offAll(() => BottomNavScreen());
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
                Stack(
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
                ),

                const SizedBox(height: 10),
                Text(
                  'Thank you!\nYour order is placed!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Our delivery team will contact you shortly.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.black),
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

Widget buildTextField(
  TextEditingController controller,
  String hint, {
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    maxLines: 1,
    textCapitalization: TextCapitalization.words,
    validator: validator,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      border: _outlineBorder(),
      enabledBorder: _outlineBorder(),
      focusedBorder: _outlineBorder(width: 2.5),
    ),
  );
}

OutlineInputBorder _outlineBorder({double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: CustomColors.baseColor, width: width),
  );
}
