import '../../services/auth_service.dart';

class SessionManager {
  static Future<bool> isSessionValid() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) return false;

    final expired = await AuthService.isTokenExpired();
    return !expired;
  }
}
