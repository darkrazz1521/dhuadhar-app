import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../services/auth_service.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getSummary() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/dashboard/summary'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load dashboard');
    }

    return jsonDecode(res.body);
  }
}
