import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class AdvanceService {
  /* --------------------------------------------------
     CREATE ADVANCE (✅ customerId based)
  -------------------------------------------------- */
  static Future<bool> createAdvance({
    required String customerId,
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
        'customerId': customerId,
        'category': category,
        'quantity': quantity,
        'advance': advance,
      }),
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }

    return response.statusCode == 201;
  }

  /* --------------------------------------------------
     GET ALL ADVANCES
  -------------------------------------------------- */
  static Future<List<dynamic>> getAdvances() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/advance'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load advances');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  /* --------------------------------------------------
     CONVERT FULL ADVANCE → SALE
  -------------------------------------------------- */
  static Future<bool> convertToSale(String id) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/advance/$id/convert'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }

    return response.statusCode == 200;
  }

  /* --------------------------------------------------
     PARTIAL DELIVERY
  -------------------------------------------------- */
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
      body: jsonEncode({
        'deliverQty': quantity,
      }),
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }

    return response.statusCode == 200;
  }
}
