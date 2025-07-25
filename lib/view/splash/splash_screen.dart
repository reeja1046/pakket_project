import 'package:flutter/material.dart';
import 'package:pakket/view/widget/bottomnavbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  void checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isSignedUp = prefs.getBool('isSignedUp') ?? false;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await Future.delayed(const Duration(seconds: 2)); // Optional splash delay

    if (isSignedUp || isLoggedIn) {
      // Either signed up or logged in → go to BottomNavScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => BottomNavScreen()),
      );
    } else {
      // Neither signed up nor logged in → go to onboarding
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 40),
              _buildSplashImage(),
              const SizedBox(height: 40),
              Image.asset(
                'assets/logo_text.png',
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image), // Fallback
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/logo.png',
      errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag), // Fallback
    );
  }

  Widget _buildSplashImage() {
    return Image.asset(
      'assets/splash/splash.png',
      errorBuilder: (_, __, ___) => const Icon(Icons.image), // Fallback
    );
  }
}
