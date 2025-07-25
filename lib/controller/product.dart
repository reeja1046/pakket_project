import 'package:pakket/controller/token_checking_helper.dart';
import 'package:pakket/model/product.dart';

Future<ProductDetail?> fetchProductDetail(String productId) async {
  final data = await getRequest('https://pakket-dev.vercel.app/api/app/product/$productId');

  if (data == null) return null; // token expired handled globally

  return ProductDetail.fromJson(data['product']);
}
