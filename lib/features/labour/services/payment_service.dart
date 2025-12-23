import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/api_config.dart';
import '../../../services/auth_service.dart';

class PaymentService {
  static Future<List<dynamic>> getSalaryLabours(
      String month) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/payment/salary?month=$month',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Failed');
    return jsonDecode(res.body);
  }

  static Future<bool> paySalary(
      Map<String, dynamic> payload) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/payment/salary/pay'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    return res.statusCode == 201;
  }
}
