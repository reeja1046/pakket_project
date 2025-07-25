import 'package:pakket/controller/token_checking_helper.dart';
import 'package:pakket/model/profile.dart';

Future<Profile?> fetchProfileData() async {
  final data = await getRequest('https://pakket-dev.vercel.app/api/app/user');

  if (data == null) return null; // token expired handled globally

  return Profile.fromJson(data);
}
