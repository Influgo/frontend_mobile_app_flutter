import 'package:frontend_mobile_app_flutter/features/events/data/services/event_service.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventService service;

  EventRepositoryImpl(this.service);

  @override
  Future<List<Event>> getEvents() async {
    final response = await service.getEvents();
    return response.content;
  }
}
