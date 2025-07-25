import 'package:pakket/controller/token_checking_helper.dart';

Future<Map<String, dynamic>?> checkLocationServiceability(String mapUrl) async {
  final data = await postRequest(
    'https://pakket-dev.vercel.app/api/app/delivery/availability',
    {'mapUrl': mapUrl},
  );

  if (data == null) return null; // token expired handled globally
  return data;
}
