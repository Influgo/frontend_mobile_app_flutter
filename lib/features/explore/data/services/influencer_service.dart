import 'dart:convert';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/influencer_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';

class InfluencerService {
  final String baseUrl = 'https://influyo-testing.ryzeon.me/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Método original
  Future<InfluencerResponse> getInfluencers(
      {int page = 0, int size = 20, String sortField = "updatedAt"}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    // Cambiar para influencer endpoint
    //final uri = Uri.parse('$baseUrl/entities/influencer?page=$page&size=$size&sortField=$sortField'),
    final response = await http.get(
      Uri.parse('$baseUrl/entities/entrepreneur?page=$page&size=$size&sortField=$sortField'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return InfluencerResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load influencers: ${response.statusCode}');
    }
  }

  // ← NUEVO: Método para búsqueda por nombre
  Future<InfluencerResponse> searchInfluencers({
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

    // Cambiar para influencer endpoint
    //final uri = Uri.parse('$baseUrl/entities/influencer').replace(
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
      return InfluencerResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to search influencers: ${response.statusCode}');
    }
  }

  // Método con filtros (del código anterior)
  Future<InfluencerResponse> getInfluencersWithFilters({
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

    // Cambiar para influencer endpoint
    //final uri = Uri.parse('$baseUrl/entities/influencer').replace(
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
      return InfluencerResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load influencers: ${response.statusCode}');
    }
  }
}
