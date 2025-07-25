import 'package:pakket/controller/token_checking_helper.dart';
import 'package:pakket/model/address.dart';

Future<Address?> addAddressApi(AddressRequest addressRequest) async {
  final data = await postRequest(
    'https://pakket-dev.vercel.app/api/app/address',
    addressRequest.toJson(),
  );

  if (data == null) return null; // token expired handled globally

  return Address.fromJson(data['address']);
}

Future<List<Address>> fetchAddresses() async {
  final data = await getRequest('https://pakket-dev.vercel.app/api/app/address');

  if (data == null) return []; // token expired handled globally

  final List<dynamic> jsonList = data['addresses'];
  return jsonList.map((json) => Address.fromJson(json)).toList();
}

Future<bool> deleteAddressApi(String addressId) async {
  final data = await deleteRequest('https://pakket-dev.vercel.app/api/app/address/$addressId');

  if (data == null) return false; // token expired handled globally

  return true;
}
