import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/api_config.dart';
import '../../../services/auth_service.dart';

class ExpenditureService {
  static Future<List<dynamic>> getElectricityExpenses() async {
  final token = await AuthService.getToken();
  final res = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/electricity'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode != 200) throw Exception('Failed');
  return jsonDecode(res.body);
}

static Future<bool> addElectricityExpense(
    Map<String, dynamic> payload) async {
  final token = await AuthService.getToken();
  final res = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/electricity'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(payload),
  );
  return res.statusCode == 201;
}


  static Future<List<dynamic>> getDieselExpenses() async {
  final token = await AuthService.getToken();
  final res = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/diesel'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode != 200) throw Exception('Failed');
  return jsonDecode(res.body);
}

static Future<bool> addDieselExpense(Map<String, dynamic> payload) async {
  final token = await AuthService.getToken();
  final res = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/diesel'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(payload),
  );

  return res.statusCode == 200 || res.statusCode == 201;
}



  static Future<List<dynamic>> getCoalExpenses() async {
  final token = await AuthService.getToken();
  final res = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/coal'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode != 200) throw Exception('Failed');
  return jsonDecode(res.body);
}

static Future<bool> addCoalExpense(Map<String, dynamic> payload) async {
  final token = await AuthService.getToken();
  final res = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/coal'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(payload),
  );
  return res.statusCode == 201;
}

  static Future<List<dynamic>> getLandExpenses() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/land'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Failed');
    return jsonDecode(res.body);
  }

  static Future<bool> addLandExpense(Map<String, dynamic> payload) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/land'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    return res.statusCode == 201;
  }
}
