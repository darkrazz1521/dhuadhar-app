import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class AdvanceService {

  static Future<bool> partialDeliver(
  String id,
  int quantity,
) async {
  final token = await AuthService.getToken();

  final response = await http.post(
    Uri.parse(
        '${ApiConfig.baseUrl}/advance/$id/partial-deliver'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({ 'deliverQty': quantity }),
  );

  return response.statusCode == 200;
}


  static Future<bool> createAdvance({
  required String customerName,
  required String category,
  required int quantity,
  required int advance,
}) async {
  final token = await AuthService.getToken();

  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/advance'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'customerName': customerName,
      'category': category,
      'quantity': quantity,
      'advance': advance,
    }),
  );

  return response.statusCode == 201;
}


  static Future<List<dynamic>> getAdvances() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/advance'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed');
    }

    return jsonDecode(response.body);
  }

  static Future<bool> convertToSale(String id) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/advance/$id/convert'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}
