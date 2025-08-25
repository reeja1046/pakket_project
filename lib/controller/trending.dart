import 'package:pakket/controller/token_checking_helper.dart';
import 'package:pakket/model/trending.dart';

Future<List<Product>> fetchTrendingProducts() async {
  final data = await getRequest(
    'https://pakket-dev.vercel.app/api/app/product/trending',
  );

  if (data == null) return []; // token expired handled globally

  List result = data['result'];
  return result.map((item) => Product.fromJson(item)).toList();
}
