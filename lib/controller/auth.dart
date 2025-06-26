import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/widget/bottomnavbar.dart';
import 'package:pakket/view/widget/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> signUp(
  String name,
  String email,
  String password,
  String phone,
  context,
) async {
  const url = 'https://pakket-dev.vercel.app/api/app/register';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );
    final data = jsonDecode(response.body);
    print(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = data['token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      _showBlurDialog(context);
    } else {
      if (data['message'] == 'Phone number already exists.') {
        showSuccessSnackbar(context, data['message']);
      } else {
        showSuccessSnackbar(context, data['error']);
      }
    }
  } catch (e) {
    showSuccessSnackbar(context, 'Something went wrong. Please try again');
  }
}

void _showBlurDialog(BuildContext context) {
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BottomNavScreen()),
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
                      'Account created\nsuccessfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You have successfully created an account with us! Get ready for a great shopping experience',
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

Future<void> login(String phone, String password, BuildContext context) async {
  const url = 'https://pakket-dev.vercel.app/api/app/login';

  final body = {"phone": phone.trim(), "password": password.trim()};

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'];
      if (token != null) {
        // ✅ Save token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        //show success snackbar
        showSuccessSnackbar(context, 'Login successful! Welcome back.');

        // ✅ Navigate to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavScreen()),
        );
      } else {
        //show failed snackbar
        showSuccessSnackbar(context, 'Token is not provided');
      }
    } else {
      print(response.body);
      //show failed snackbar
      showSuccessSnackbar(context, data['message']);
    }
  } catch (e) {
    showSuccessSnackbar(context, 'An error occurred. Please try again.');
  }
}
