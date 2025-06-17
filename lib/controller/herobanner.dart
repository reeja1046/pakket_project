import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakket/model/herobanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<HeroBanner>> fetchHeroBanners() async {
  final token = await getToken();
  print(token);
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
  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    final List banners = body['result'];
    return banners.map((json) => HeroBanner.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load hero banners: ${response.body}');
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
