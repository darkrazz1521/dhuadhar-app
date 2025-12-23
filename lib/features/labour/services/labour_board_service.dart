import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/api_config.dart';
import '../../../services/auth_service.dart';

class LabourBoardService {
  static Future<Map<String, dynamic>> getSummary() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/labour-board'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Failed');
    return jsonDecode(res.body);
  }
}
