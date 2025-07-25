import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:pakket/view/auth/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central function to handle token check and navigation
Future<Map<String, dynamic>?> handleResponse(http.Response response) async {
  final Map<String, dynamic> data = jsonDecode(response.body);

  if (data['token_expired'] == true) {
    // Clear token and navigate to login
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Get.offAll(() => const SignInScreen());
    return null;
  }

  return data;
}

/// Helper for GET request
Future<Map<String, dynamic>?> getRequest(String url) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $token'},
  );

  return handleResponse(response);
}

/// Helper for POST request
Future<Map<String, dynamic>?> postRequest(
  String url,
  Map<String, dynamic> body,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  return handleResponse(response);
}

/// Helper for DELETE request
Future<Map<String, dynamic>?> deleteRequest(String url) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final response = await http.delete(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $token'},
  );

  return handleResponse(response);
}

//for patch data
Future<Map<String, dynamic>?> patchRequest(
  String url,
  Map<String, dynamic> body,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final response = await http.patch(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  return handleResponse(response);
}
