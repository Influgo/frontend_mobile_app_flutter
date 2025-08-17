import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/data/models/calendar_event_model.dart';

class CalendarService {
  static const String baseUrl = 'https://influyo-testing.ryzeon.me/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<int?> _getEntrepreneurId() async {
    final token = await _getToken();
    if (token == null) {
      print('❌ No token found for entrepreneur ID retrieval');
      return null;
    }

    try {
      // Usar el endpoint específico para obtener datos del emprendedor autenticado
      final response = await http.get(
        Uri.parse('$baseUrl/entities/entrepreneur/self'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final entrepreneurId = data['id'];
        print('✅ Entrepreneur ID obtenido: $entrepreneurId');
        return entrepreneurId;
      } else {
        print('❌ Error obteniendo entrepreneur ID: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception obteniendo entrepreneur ID: $e');
      return null;
    }
  }

  /// Obtiene los eventos de un mes específico para un emprendedor
  Future<List<CalendarEventResponse>> getEventsForMonth({
    required int year,
    required int month,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final entrepreneurId = await _getEntrepreneurId();
    if (entrepreneurId == null) {
      throw Exception('No entrepreneur ID found');
    }

    print('Calling calendar API with: entrepreneurId=$entrepreneurId, year=$year, month=$month'); // Debug

    final response = await http.get(
      Uri.parse('$baseUrl/entities/events/schedule/month?entrepreneurId=$entrepreneurId&year=$year&month=$month'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      print('📨 Calendar API Raw Response: $responseBody'); // Debug
      print('📊 Response status: ${response.statusCode}'); // Debug
      
      try {
        print('🔍 Attempting to decode JSON...'); // Debug
        final List<dynamic> jsonList = json.decode(responseBody);
        print('✅ JSON decoded successfully. Found ${jsonList.length} items'); // Debug
        print('📋 Parsed JSON List: $jsonList'); // Debug
        
        return jsonList.map((json) {
          print('📅 Processing calendar item: $json'); // Debug
          try {
            return CalendarEventResponse.fromJson(json);
          } catch (e) {
            print('❌ Error parsing calendar item: $e'); // Debug
            print('📋 Problematic JSON: $json'); // Debug
            rethrow;
          }
        }).toList();
      } catch (e) {
        print('Error parsing calendar response: $e'); // Debug
        rethrow;
      }
    } else {
      print('Calendar API Error: ${response.statusCode} - ${response.body}'); // Debug
      throw Exception('Failed to load calendar events: ${response.statusCode} - ${response.body}');
    }
  }
}
