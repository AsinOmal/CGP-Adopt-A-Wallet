import 'package:shared_preferences/shared_preferences.dart';

class ProfileImageService {
  Future<void> saveImageUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_url', url);
  }

  Future<String?> getImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_url');
  }
}
