import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/influencer_model.dart';

// Modelo para las aplicaciones (pending y accepted)
class EventApplication {
  final String status;
  final Influencer influencer;

  EventApplication({
    required this.status,
    required this.influencer,
  });

  factory EventApplication.fromJson(Map<String, dynamic> json) {
    return EventApplication(
      status: json['status'] ?? '',
      influencer: Influencer.fromJson(json['influencer'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      // El influencer toJson lo implementaremos si es necesario
    };
  }
}

// Modelo extendido del evento que incluye las aplicaciones
class ExtendedEvent {
  final Event event;
  final List<EventApplication> pendingApplications;
  final List<EventApplication> acceptedApplications;

  ExtendedEvent({
    required this.event,
    required this.pendingApplications,
    required this.acceptedApplications,
  });

  factory ExtendedEvent.fromJson(Map<String, dynamic> json) {
    return ExtendedEvent(
      event: Event.fromJson(json['event'] ?? {}),
      pendingApplications: (json['pendingApplications'] as List<dynamic>? ?? [])
          .map((app) => EventApplication.fromJson(app))
          .toList(),
      acceptedApplications: (json['acceptedApplications'] as List<dynamic>? ?? [])
          .map((app) => EventApplication.fromJson(app))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Solo incluiremos las aplicaciones por ahora
      'pendingApplications': pendingApplications.map((app) => app.toJson()).toList(),
      'acceptedApplications': acceptedApplications.map((app) => app.toJson()).toList(),
    };
  }

  // Métodos utilitarios
  List<EventApplication> get allApplications => [...pendingApplications, ...acceptedApplications];
  
  int get totalApplications => pendingApplications.length + acceptedApplications.length;
  
  bool get hasPendingApplications => pendingApplications.isNotEmpty;
  
  bool get hasAcceptedApplications => acceptedApplications.isNotEmpty;

  // Método para obtener solo las aplicaciones pendientes
  List<EventApplication> getPendingApplications() {
    return pendingApplications.where((app) => app.status == 'PENDING').toList();
  }

  // Método para obtener solo las aplicaciones aceptadas
  List<EventApplication> getAcceptedApplications() {
    return acceptedApplications.where((app) => app.status == 'ACCEPTED').toList();
  }
}