import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/api_config.dart';
import '../../../services/auth_service.dart';

class AttendanceService {
  // ------------------------------
  // GET DAILY ATTENDANCE
  // ------------------------------
  static Future<List<dynamic>> getDaily(String date) async {
    final token = await AuthService.getToken();

    final res = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/attendance/daily/$date',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load attendance');
    }

    return jsonDecode(res.body);
  }

  // ------------------------------
  // SAVE DAILY ATTENDANCE
  // ------------------------------
  static Future<bool> save(
    String date,
    List<Map<String, dynamic>> entries,
  ) async {
    final token = await AuthService.getToken();

    final res = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/attendance/daily/$date',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'entries': entries,
      }),
    );

    return res.statusCode == 200;
  }
}
