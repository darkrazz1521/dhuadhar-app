import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/api_config.dart';
import '../../../services/auth_service.dart';

class LabourService {
  static Future<List<dynamic>> getLabours() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/labour'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Failed');
    return jsonDecode(res.body);
  }

  static Future<bool> addLabour(Map<String, dynamic> payload) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/labour'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    return res.statusCode == 201;
  }

  static Future<bool> toggleStatus(String id) async {
    final token = await AuthService.getToken();
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/labour/$id/toggle'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200;
  }
}
