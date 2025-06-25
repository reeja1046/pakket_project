import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pakket/controller/auth.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/auth/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.04,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.2),

                SizedBox(
                  height: size.height * 0.15,
                  child: Image.asset('assets/logo.png'),
                ),
                Text(
                  'Existing user',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Please add your details',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),

                SizedBox(height: size.height * 0.04),

                CustomTextField(
                  hint: "WhatsApp no.",
                  controller: phoneController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your mobile number';
                    } else if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                      return 'Enter a valid 10-digit number';
                    }
                    return null;
                  },
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/auth/wtspicon.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),

                CustomTextField(
                  hint: "**********",
                  controller: passwordController,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.03),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Forgot password? ',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[900],
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: 'Reset',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: CustomColors.baseColor,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).pushNamed('/phonenumber');
                            },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.035),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.baseColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.015,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                        'phonenumber',
                        phoneController.text,
                      );
                      // Handle sign-in
                      login(
                        phoneController.text,
                        passwordController.text,
                        context,
                      );
                    }
                  },
                  child: const Text(
                    'SUBMIT NOW',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
