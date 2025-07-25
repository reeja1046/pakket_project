import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> getPincodes() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final url = Uri.parse(
    'https://pakket-dev.vercel.app/api/app/delivery/pincodes',
  );

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['success'] == true && data['pincodes'] != null) {
      return List<String>.from(data['pincodes'].map((e) => e['postcode']));
    } else {
      throw Exception('Invalid response structure');
    }
  } else {
    throw Exception('Failed to fetch pincodes');
  }
}
