import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class SalesService {
  /* -------------------- REPORT SUMMARY -------------------- */
  static Future<Map<String, int>> getReportSummary() async {
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

    final data = jsonDecode(response.body);

    return {
      'totalSales': data['totalSales'],
      'totalPaid': data['totalPaid'],
      'totalDue': data['totalDue'],
      'totalAdvance': data['totalAdvance'],
    };
  }

  /* -------------------- SET PRICE (OWNER) -------------------- */
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

  /* -------------------- GET PRICES -------------------- */
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

    final List data = jsonDecode(response.body);

    return {
      for (var item in data) item['category']: item['rate'],
    };
  }

  /* -------------------- CREATE SALE -------------------- */
  static Future<bool> createSale({
    required String customerName,
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
        'customerName': customerName,
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
}
