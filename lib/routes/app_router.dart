import 'package:flutter/material.dart';
import 'package:pakket/routes/app_routes.dart';
import 'package:pakket/view/auth/password_reset.dart';
import 'package:pakket/view/auth/signin.dart';
import 'package:pakket/view/auth/signup.dart';
import 'package:pakket/view/home/home.dart';
import 'package:pakket/view/splash/onboarding.dart';
import 'package:pakket/view/splash/splash_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case AppRoutes.signin:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case AppRoutes.passwordreset:
        return MaterialPageRoute(builder: (_) => const PasswordReset());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("No route defined"))),
        );
    }
  }
}
