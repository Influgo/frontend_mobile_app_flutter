import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';

class EventService {
  final String baseUrl = 'https://influyo-testing.ryzeon.me/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<EventResponse> getEvents({int page = 0, int size = 10}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/entities/events?page=$page&size=$size'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('API Response: ${response.body}');
        final jsonResponse = json.decode(response.body);

        // Test parsing each event individually to find the problematic one
        if (jsonResponse['content'] != null &&
            jsonResponse['content'] is List) {
          for (int i = 0; i < jsonResponse['content'].length; i++) {
            try {
              final eventJson = jsonResponse['content'][i];
              print(
                  'Checking event $i with keys: ${eventJson.keys.join(", ")}');

              // Check for null values that should be strings
              eventJson.forEach((key, value) {
                if (value == null) {
                  print('WARNING: Event $i has null value for field "$key"');
                }
              });

              // Try to create the Event object
              Event.fromJson(eventJson);
            } catch (e) {
              print('Error parsing event $i: $e');
            }
          }
        }

        return EventResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to load events: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Service error: ${e.toString()}');
      throw Exception('Service error: ${e.toString()}');
    }
  }

  // Get event by ID
  Future<Event> getEventById(int eventId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/entities/events/$eventId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Event.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load event details: ${response.statusCode}');
    }
  }

  // Get events by filter (you can implement additional filters as needed)
  Future<EventResponse> getEventsByFilter({
    String? keyword,
    DateTime? startAfter,
    DateTime? endBefore,
    int page = 0,
    int size = 10,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    // Build query parameters
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };

    if (keyword != null && keyword.isNotEmpty) {
      queryParams['keyword'] = keyword;
    }

    if (startAfter != null) {
      queryParams['startAfter'] = startAfter.toIso8601String();
    }

    if (endBefore != null) {
      queryParams['endBefore'] = endBefore.toIso8601String();
    }

    final uri = Uri.parse('$baseUrl/entities/events')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return EventResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load filtered events: ${response.statusCode}');
    }
  }
}
