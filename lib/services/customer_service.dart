import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class CustomerService {
  static Future<List<dynamic>> search(String q) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/customers?q=$q'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) {
      throw Exception('Failed');
    }
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> create(
      Map<String, dynamic> payload) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/customers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed');
    }
    return jsonDecode(res.body);
  }
}
