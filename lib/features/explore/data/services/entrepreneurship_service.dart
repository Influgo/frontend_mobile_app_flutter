import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';

class EntrepreneurshipService {
  final String baseUrl = 'https://influyo-testing.ryzeon.me/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Método original
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

  // ← NUEVO: Método para búsqueda por nombre
  Future<EntrepreneurshipResponse> searchEntrepreneurships({
    required String name,
    int page = 0,
    int size = 20,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    // Construir query parameters
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
      'name': name, // ← Parámetro de búsqueda por nombre
    };

    final uri = Uri.parse('$baseUrl/entities/entrepreneur').replace(
      queryParameters: queryParams,
    );

    print('🔍 Búsqueda API: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return EntrepreneurshipResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to search entrepreneurships: ${response.statusCode}');
    }
  }

  // Método con filtros (del código anterior)
  Future<EntrepreneurshipResponse> getEntrepreneurshipsWithFilters({
    int page = 0,
    int size = 50,
    List<String>? categories,
    String? location,
    String? modality,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    Map<String, String> queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };

    if (categories != null &&
        categories.isNotEmpty &&
        !categories.contains("Todos")) {
      queryParams['categories'] = categories.join(',');
    }

    if (location != null && location != "Lima") {
      queryParams['location'] = location;
    }

    if (modality != null && modality != "Todos") {
      queryParams['modality'] = modality;
    }

    final uri = Uri.parse('$baseUrl/entities/entrepreneur').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(
      uri,
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
