import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/auth/password_reset.dart';
import 'package:pakket/view/auth/widget.dart';
import 'package:pakket/view/widget/snackbar.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    String phone = phoneController.text.trim();

    if (phone.isEmpty || phone.length < 10) {
      showSuccessSnackbar(context, 'Please enter a valid phone number');

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://pakket-dev.vercel.app/api/app/forgot-password/sent-otp',
        ), // replace with actual API base URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      final data = jsonDecode(response.body);
      print(data);
      if (response.statusCode == 200 && data['success'] == true) {
        // Navigate to OTP screen and pass phone number
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => PasswordReset(phone: phone)),
        );
      } else {
        showSuccessSnackbar(context, data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      showSuccessSnackbar(context, 'Error: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.035),
                SizedBox(
                  height: size.height * 0.1,
                  child: Image.asset('assets/logo.png'),
                ),
                SizedBox(height: size.height * 0.03),
                const Text(
                  'Reset your Password',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'You can reset your password by adding\nfollowing details',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: size.height * 0.08),
                const Text(
                  'Enter the Registered Whatsapp no.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.03),
                CustomTextField(
                  keyboardtype: TextInputType.phone,
                  hint: "Phone number",
                  controller: phoneController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    } else if (value.length < 10) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.06),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.baseColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.015,
                      ),
                    ),
                    onPressed: isLoading ? null : sendOtp,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send OTP',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
