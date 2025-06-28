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
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Optional: Add a small splash delay
    await Future.delayed(const Duration(seconds: 2));

    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => BottomNavScreen()),
      );
    } else {
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
