import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/api_config.dart';
import '../../../services/auth_service.dart';

class AttendanceService {
  static Future<List<dynamic>> getDaily(String date) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/attendance?date=$date',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Failed');
    return jsonDecode(res.body);
  }

  static Future<bool> save(
    String date,
    List<Map<String, dynamic>> entries,
  ) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/attendance'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'date': date,
        'entries': entries,
      }),
    );
    return res.statusCode == 200;
  }
}
