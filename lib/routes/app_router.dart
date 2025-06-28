import 'package:get/get.dart';
import 'package:pakket/view/auth/phonenumber.dart';
import 'package:pakket/view/auth/signin.dart';
import 'package:pakket/view/auth/signup.dart';
import 'package:pakket/view/home/home.dart';
import 'package:pakket/view/profile/profile.dart';
import 'package:pakket/view/search/search.dart';
import 'package:pakket/view/splash/onboarding.dart';
import 'package:pakket/view/splash/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.onboarding, page: () => OnboardingScreen(),),
    GetPage(name: AppRoutes.signup, page: () => const SignUpScreen()),
    GetPage(name: AppRoutes.signin, page: () => const SignInScreen()),
    // GetPage(
    //   name: AppRoutes.passwordreset,
    //   page: () => const PasswordReset(),
    // ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
    GetPage(name: AppRoutes.search, page: () => const SearchDetails()),
    GetPage(name: AppRoutes.phone, page: () => const PhoneNumberScreen()),
    // GetPage(
    //   name: AppRoutes.productdetail,
    //   page: () {
    //     final args = Get.arguments as ProductDetail;
    //     return ProductDetails(details: args);
    //   },
    // ),
  ];
}
