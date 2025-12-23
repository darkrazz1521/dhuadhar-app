import 'package:shared_preferences/shared_preferences.dart';

class RoleHelper {
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');

    // 🔥 DEBUG LOG (VERY IMPORTANT)
    print('🔐 STORED ROLE => $role');

    return role;
  }

  static Future<bool> isOwner() async {
    final role = await getRole();
    final isOwner = role == 'owner';

    // 🔥 DEBUG LOG
    print('👑 IS OWNER => $isOwner');

    return isOwner;
  }
}
