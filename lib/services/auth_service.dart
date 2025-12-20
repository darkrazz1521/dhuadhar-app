import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class AuthService {
  /* -------------------- LOGIN -------------------- */
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        // 🔐 Save token
        await prefs.setString('token', data['token']);

        // 📦 Save role (IMPORTANT)
        await prefs.setString('role', data['user']['role']);

        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /* -------------------- LOGOUT -------------------- */
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role'); // 👈 clear role
  }

  /* -------------------- TOKEN -------------------- */
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  /* -------------------- ROLE -------------------- */
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<bool> isOwner() async {
    final role = await getRole();
    return role == 'owner';
  }

  /* -------------------- TOKEN EXPIRY -------------------- */
  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return true;

    final payload = _decodeJWT(token);
    if (payload == null) return true;

    final expiry = payload['exp'] * 1000;
    return DateTime.now().millisecondsSinceEpoch > expiry;
  }

  /* -------------------- JWT DECODER -------------------- */
  static Map<String, dynamic>? _decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return jsonDecode(payload);
    } catch (_) {
      return null;
    }
  }
}
