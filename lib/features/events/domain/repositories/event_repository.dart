import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
}
