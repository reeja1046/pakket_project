import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakket/model/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Profile> fetchProfileData() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final response = await http.get(
    Uri.parse('https://pakket-dev.vercel.app/api/app/user'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  print(response.body);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return Profile.fromJson(data);
  } else {
    throw Exception('Failed to load profile data: ${response.body}');
  }
}
