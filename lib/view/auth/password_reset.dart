import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/auth/widget.dart';
import 'package:pinput/pinput.dart';

class PasswordReset extends StatefulWidget {
  String phone;
  PasswordReset({super.key, required this.phone});

  @override
  State<PasswordReset> createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    otpController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> verifyOtpAndResetPassword() async {
    String otp = otpController.text.trim();
    String newPassword = passwordController.text.trim();

    if (otp.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enter the complete 6-digit OTP')));
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final resetResponse = await http.post(
        Uri.parse(
          'https://pakket-dev.vercel.app/api/app/forgot-password/reset-password',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phone,
          'otp': otp,
          'password': newPassword,
        }),
      );

      final resetData = jsonDecode(resetResponse.body);

      if (resetResponse.statusCode == 200 && resetData['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Password reset successful')));
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/signin', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resetData['message'] ?? 'Password reset failed'),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CustomColors.baseColor, width: 1),
      ),
    );

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
                  'Enter the OTP Code received from your\nRegistered Whatsapp no.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.03),

                // Pinput OTP Box
                Pinput(
                  length: 6,
                  controller: otpController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: CustomColors.baseColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                  // androidSmsAutofillMethod:
                  //     AndroidSmsAutofillMethod.smsRetrieverApi,
                  showCursor: true,
                ),

                SizedBox(height: size.height * 0.06),
                CustomTextField(
                  hint: "*New password",
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
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
                    onPressed: isLoading ? null : verifyOtpAndResetPassword,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SUBMIT NOW',
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
