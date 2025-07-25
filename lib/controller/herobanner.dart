import 'package:pakket/controller/token_checking_helper.dart';
import 'package:pakket/model/herobanner.dart';

Future<List<HeroBanner>> fetchHeroBanners() async {
  final data = await getRequest(
      'https://pakket-dev.vercel.app/api/app/offers/hero-banner');

  if (data == null) return []; // token expired handled globally

  final List banners = data['result'];
  return banners.map((json) => HeroBanner.fromJson(json)).toList();
}
