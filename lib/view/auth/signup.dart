import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pakket/controller/auth.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/auth/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false, // Prevent default back navigation
      onPopInvoked: (didPop) {
        if (!didPop) {
          SystemNavigator.pop(); // Exit the app
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.05,
              size.height * 0.04,
              size.width * 0.05,
              MediaQuery.of(context).viewPadding.bottom +
                  16, // This ensures space for gesture/navigation bar
            ),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.035),
                SizedBox(
                  height: size.height * 0.1,
                  child: Image.asset('assets/logo.png'),
                ),
                SizedBox(height: size.height * 0.03),
                const Text(
                  'Create New Account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Set up your username and password.\nYou can always change it later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: size.height * 0.015),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        CustomTextField(
                          hint: "Your Name",
                          controller: nameController,
                          validator: (value) => value!.isEmpty
                              ? "Please enter your full name"
                              : null,
                        ),
                        CustomTextField(
                          hint: "Your email id",
                          controller: emailController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter a valid email address";
                            }
                            if (!RegExp(
                              r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$',
                            ).hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          hint: "Whatsapp no.",
                          controller: phoneController,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              'assets/auth/wtspicon.png',
                              width: 24,
                              height: 24,
                            ),
                          ),

                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter your phone number";
                            }
                            if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                              return "Enter a valid 10-digit phone number";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          hint: "AS*(@L_@(P123",
                          controller: passwordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please create a password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          hint: "**********",
                          controller: confirmPasswordController,
                          isPassword: true,
                          isPasswordVisible: isConfirmPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) return "Confirm your password";
                            if (value != passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height * 0.025),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.baseColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.018,
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                'phonenumber',
                                phoneController.text,
                              );
                              // Proceed with form submission
                              signUp(
                                nameController.text,
                                emailController.text,
                                passwordController.text,
                                phoneController.text,
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
                        SizedBox(height: size.height * 0.06),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              children: [
                                TextSpan(
                                  text: 'Log in',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CustomColors.baseColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Navigate to login
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/signin');
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                      ],
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
