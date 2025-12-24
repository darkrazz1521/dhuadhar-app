import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class CreditService {

  static Future<Map<String, dynamic>> getCustomerSummary(
  String customerId,
) async {
  final token = await AuthService.getToken();

  final res = await http.get(
    Uri.parse(
      '${ApiConfig.baseUrl}/credit/customer/$customerId/summary',
    ),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to load credit summary');
  }

  return jsonDecode(res.body);
}


  static Future<List<dynamic>> getPaymentHistory(
  String customerId,
) async {
  final token = await AuthService.getToken();

  final response = await http.get(
    Uri.parse(
        '${ApiConfig.baseUrl}/credit/$customerId/payments'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed');
  }

  return jsonDecode(response.body);
}


  static Future<Map<String, dynamic>> getCreditByCustomer(
  String customerId,
) async {
  final token = await AuthService.getToken();

  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/credit/$customerId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed');
  }

  return jsonDecode(response.body);
}


  static Future<List<dynamic>> getCredits() async {
  final token = await AuthService.getToken();

  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/credit'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed');
  }

  return jsonDecode(response.body);
}

  static Future<bool> clearCredit({
    required String customerId,
    required int amount,
  }) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/credit/clear'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'customerId': customerId,
        'amount': amount,
      }),
    );

    return response.statusCode == 200;
  }
}
