import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class SalesService {

  static Future<List<dynamic>> getSalesByCustomer(
  String customerId,
) async {
  final token = await AuthService.getToken();

  final res = await http.get(
    Uri.parse(
      '${ApiConfig.baseUrl}/sales/customer/$customerId',
    ),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to load sales');
  }

  return jsonDecode(res.body);
}

  /* --------------------------------------------------------
   * GET TODAY SALES (Sales Board)
   * ------------------------------------------------------ */
  static Future<List<dynamic>> getTodaySales() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/sales/today'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load today sales');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  /* --------------------------------------------------------
   * GET PRICES (Sales Now + Price Setting)
   * ------------------------------------------------------ */
  static Future<Map<String, int>> getPrices() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/prices'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load prices');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return data.map(
      (key, value) => MapEntry(key, value as int),
    );
  }

  /* --------------------------------------------------------
   * SET PRICE (OWNER ONLY) ✅ FIXED
   * ------------------------------------------------------ */
  static Future<bool> setPrice({
    required String category,
    required int rate,
  }) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/prices'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'category': category,
        'rate': rate,
      }),
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }

    return response.statusCode == 200;
  }

  /* --------------------------------------------------------
   * CREATE SALE (customerId based) ✅ FINAL
   * ------------------------------------------------------ */
  static Future<bool> createSale({
    required String customerId,
    required String category,
    required int quantity,
    required int paid,
  }) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/sales'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'customerId': customerId,
        'category': category,
        'quantity': quantity,
        'paid': paid,
      }),
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }

    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>> getSaleDetail(
  String saleId,
) async {
  final token = await AuthService.getToken();

  final res = await http.get(
    Uri.parse(
      '${ApiConfig.baseUrl}/sales/$saleId/detail',
    ),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to load sale detail');
  }

  return jsonDecode(res.body);
}


  /* --------------------------------------------------------
   * REPORT SUMMARY (Reports Screen)
   * ------------------------------------------------------ */
  static Future<Map<String, dynamic>> getReportSummary() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/reports/summary'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load report summary');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
