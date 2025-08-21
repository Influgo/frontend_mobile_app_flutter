import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';

class CalendarEventResponse {
  final Event event;
  final List<dynamic> pendingApplications;
  final List<dynamic> acceptedApplications;

  CalendarEventResponse({
    required this.event,
    required this.pendingApplications,
    required this.acceptedApplications,
  });

  factory CalendarEventResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('🔄 Parsing CalendarEventResponse from: ${json.keys}'); // Debug
      
      if (!json.containsKey('event')) {
        throw Exception('Missing "event" key in calendar response');
      }
      
      print('📝 Event data: ${json['event']}'); // Debug
      
      return CalendarEventResponse(
        event: Event.fromJson(json['event']),
        pendingApplications: json['pendingApplications'] ?? [],
        acceptedApplications: json['acceptedApplications'] ?? [],
      );
    } catch (e) {
      print('❌ CalendarEventResponse parsing error: $e'); // Debug
      rethrow;
    }
  }
}
