import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakket/model/herobanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<HeroBanner>> fetchHeroBanners() async {
  final token = await getToken();
  // final token =
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZTAxNjY1N2M2MDQzY2YyOGVmYjY2YyIsImlhdCI6MTc1MDg1OTkyNywiZXhwIjoxNzUxNDY0NzI3fQ.bCnx8XhMQgLjPW1F9bqK4JFc9Juud_gjAS4Tcs4FLhQ';
  if (token == null) {
    throw Exception('No token found');
  }

  final url = Uri.parse(
    'https://pakket-dev.vercel.app/api/app/offers/hero-banner',
  );

  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );
  final body = json.decode(response.body);
  if (response.statusCode == 200) {
    final List banners = body['result'];
    return banners.map((json) => HeroBanner.fromJson(json)).toList();
  }
  // else if (body['token_expired'] == true) {
  //   // print('login');
  //   // // Token expired, redirect to SignInPage
  //   // await clearToken();
  //   // // redirectToSignIn();
  //   throw Exception('Token expired');
  // }
  else {
    throw Exception('Failed to load hero banners: ${response.body}');
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

// Future<void> clearToken() async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('token');
// }

// void redirectToSignIn() {
//   Navigator.of(context).pushAndRemoveUntil(
//     MaterialPageRoute(builder: (context) => SignInScreen()),
//     (Route<dynamic> route) => false,
//   );
// }


