import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class ReportService {
  /// 📊 Fetch sales + expense + profit summary (OWNER ONLY)
  static Future<Map<String, dynamic>> getSummary() async {
    final token = await AuthService.getToken();

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/reports/summary'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load summary');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
