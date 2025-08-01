import 'package:get/get.dart';
import 'package:pakket/model/herobanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAdController extends GetxController {
  final Rxn<HomeBanner> homeBanner = Rxn<HomeBanner>();
  final Rxn<HomeCheckoutBanner> checkoutbanner = Rxn<HomeCheckoutBanner>();
  final GetConnect connect = GetConnect();

  @override
  void onInit() {
    super.onInit();
    fetchHomeBanner(); // use the passed type
    fetchCartBanner();
  }

  Future<void> fetchHomeBanner() async {
    final token = await getToken();
    if (token == null) {
      print('No token found');
      return;
    }

    print('*********');
    try {
      final response = await connect.get(
        'https://pakket-dev.vercel.app/api/app/offers/banner?type=home-banner',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && response.body['success'] == true) {
        final result = response.body['result'];
        if (result != null) {
          homeBanner.value = HomeBanner.fromJson(result);
          print('Banner fetched: ${homeBanner.value}');
        }
      } else {
        print('Failed to fetch banner: ${response.body}');
      }
    } catch (e) {
      print('Error fetching banner: $e');
    }
  }

  Future<void> fetchCartBanner() async {
    final token = await getToken();
    if (token == null) {
      print('No token found');
      return;
    }

    try {
      final response = await connect.get(
        'https://pakket-dev.vercel.app/api/app/offers/banner?type=checkout-banner',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && response.body['success'] == true) {
        final result = response.body['result'];
        if (result != null) {
          checkoutbanner.value = HomeCheckoutBanner.fromJson(result);
          print('Banner fetched: ${checkoutbanner.value}');
        }
      } else {
        print('Failed to fetch banner: ${response.body}');
      }
    } catch (e) {
      print('Error fetching banner: $e');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
