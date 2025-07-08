import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static const _tokenKey = 'token';
  static Future<void> saveToken(String token) async {
    (await SharedPreferences.getInstance()).setString(_tokenKey, token);
  }

  static Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString(_tokenKey);
  static Future<bool> hasToken() async =>
      (await SharedPreferences.getInstance()).containsKey(_tokenKey);
  static Future<void> removeToken() async =>
      (await SharedPreferences.getInstance()).remove(_tokenKey);
}
