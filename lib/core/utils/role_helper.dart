import 'package:shared_preferences/shared_preferences.dart';

class RoleHelper {
  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? 'staff';
  }

  static Future<bool> isOwner() async {
    final role = await getRole();
    return role == 'owner';
  }
}
