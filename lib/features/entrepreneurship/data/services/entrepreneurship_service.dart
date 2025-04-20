import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_mobile_app_flutter/features/entrepreneurship/data/models/entrepreneurship_model.dart';

class EntrepreneurshipService {
  final String baseUrl = 'https://influyo-testing.ryzeon.me/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<EntrepreneurshipResponse> getEntrepreneurships(
      {int page = 0, int size = 10}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/entities/entrepreneur?page=$page&size=$size'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return EntrepreneurshipResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load entrepreneurships: ${response.statusCode}');
    }
  }
}
