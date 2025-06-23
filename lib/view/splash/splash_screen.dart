import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Navigation timer
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel(); // Prevent memory leaks
    super.dispose();
  }

  void _initializeSplash() {
    _navigationTimer = Timer(
      const Duration(seconds: 4),
      () => Navigator.of(context).pushReplacementNamed('/onboarding'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            const SizedBox(height: 40),
            _buildSplashImage(),
            const SizedBox(height: 40),
            Image.asset(
              'assets/logo_text.png',
              errorBuilder: (_, __, ___) => const Icon(Icons.image), // Fallback
            ),
          
          ],
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
