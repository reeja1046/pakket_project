import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/order.dart';


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
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OrderScreen()),
        );
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
                const CircleAvatar(radius: 40, backgroundColor: Colors.white),
                const SizedBox(height: 8),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: CustomColors.baseColor,
                  child: const Icon(Icons.check, color: Colors.white, size: 35),
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

Widget buildTextField(TextEditingController controller, String hint) {
  return TextFormField(
    controller: controller,
    maxLines: 1,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
