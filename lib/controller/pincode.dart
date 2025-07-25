import 'package:pakket/controller/token_checking_helper.dart';

Future<List<String>> getPincodes() async {
  final data = await getRequest('https://pakket-dev.vercel.app/api/app/delivery/pincodes');

  if (data == null) return []; // token expired handled globally

  if (data['success'] == true && data['pincodes'] != null) {
    return List<String>.from(data['pincodes'].map((e) => e['postcode']));
  } else {
    throw Exception('Invalid response structure');
  }
}
