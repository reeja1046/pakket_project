import 'package:http/http.dart' as http;
import 'package:pakket/model/address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Add Address API: Returns the newly created Address object
Future<Address?> addAddressApi(AddressRequest addressRequest) async {
  print(addressRequest.toJson());
  final url = Uri.parse('https://pakket-dev.vercel.app/api/app/address');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(addressRequest.toJson()),
    );

    print('Add Address Status: ${response.statusCode}');
    print(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      //need to show address is deliverable

      // Assuming the API returns the newly created address object
      return Address.fromJson(responseData['address']);
    } else {
      print('Failed to add address: ${response.body}');

      return null;
    }
  } catch (e) {
    print('Error adding address: $e');
    return null;
  }
}

/// Fetch Address API: Returns the list of addresses
Future<List<Address>> fetchAddresses() async {
  final url = Uri.parse('https://pakket-dev.vercel.app/api/app/address');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  try {
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body)['addresses'];
      return jsonList.map((json) => Address.fromJson(json)).toList();
    } else {
      print('Failed to fetch addresses: ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error fetching addresses: $e');
    return [];
  }
}

//delete address
Future<bool> deleteAddressApi(String addressId) async {
  final url = Uri.parse(
    'https://pakket-dev.vercel.app/api/app/address/$addressId',
  );
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  try {
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Delete Address Status: ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      print('Failed to delete address: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error deleting address: $e');
    return false;
  }
}
