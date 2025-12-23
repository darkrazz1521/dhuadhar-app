import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final role = prefs.getString('role');

    // ❌ Invalid session if token OR role missing
    if (token == null || role == null) {
      await prefs.remove('token');
      await prefs.remove('role');
      return false;
    }

    // ❌ Token expired
    final expired = await AuthService.isTokenExpired();
    if (expired) {
      await prefs.remove('token');
      await prefs.remove('role');
      return false;
    }

    // ✅ Session valid
    return true;
  }
}
