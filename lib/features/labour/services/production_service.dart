import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/api_config.dart';
import '../../../services/auth_service.dart';

class ProductionService {
  static Future<List<dynamic>> get(
      String type, String date) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/production?type=$type&date=$date',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Failed');
    return jsonDecode(res.body);
  }

  static Future<bool> save(
      String type,
      String date,
      List<Map<String, dynamic>> entries) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/production'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'date': date,
        'entries': entries,
      }),
    );
    return res.statusCode == 200;
  }
}
