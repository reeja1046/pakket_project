import 'package:flutter/material.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/auth/widget.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
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
                  hint: "Phone number",
                  controller: phoneController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 10) {
                      return 'Enter valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.06),
                SizedBox(
                  width: double.infinity, // This makes the button full width
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
                    onPressed: () {
                      Navigator.of(context).pushNamed('/passwordreset');
                    },
                    child: const Text(
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
