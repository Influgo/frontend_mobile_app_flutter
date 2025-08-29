import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/influencer_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Modelo para las aplicaciones (pending y accepted)
class EventApplication {
  final int? id;  // ID de la aplicación
  final String status;
  final Influencer influencer;

  EventApplication({
    this.id,
    required this.status,
    required this.influencer,
  });

  factory EventApplication.fromJson(Map<String, dynamic> json) {
    return EventApplication(
      id: json['id'] as int?,  // Puede venir del JSON o ser null
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
    return acceptedApplications.where((app) => app.status == 'APPROVED').toList();
  }

  // Método para cambiar el estado de una aplicación de PENDING a APPROVED
  Future<bool> approveApplication(int influencerId) async {
    try {
      // 1. Obtener token para autenticación
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        print('❌ No hay token de autenticación');
        return false;
      }

      // 2. Buscar la aplicación en la lista de pendientes
      final applicationIndex = pendingApplications.indexWhere(
        (app) => app.influencer.id == influencerId
      );
      
      if (applicationIndex == -1) {
        print('❌ No se encontró aplicación pendiente para influencer ID: $influencerId');
        return false;
      }

      final application = pendingApplications[applicationIndex];
      
      // Verificar que la aplicación tenga ID
      if (application.id == null) {
        print('❌ La aplicación no tiene ID');
        return false;
      }

      // 3. Hacer llamada al backend para aprobar la aplicación
      print('🌐 Llamando al backend para aprobar aplicación con ID: ${application.id}');
      final response = await http.put( 
        Uri.parse('https://influyo-testing.ryzeon.me/api/v1/entities/event-applications/${application.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': 'APPROVED'
        }),
      );

      print('📡 Respuesta del backend: ${response.statusCode}');

      // 4. Si el backend responde OK, actualizar localmente
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Crear una nueva aplicación con estado APPROVED
        final approvedApplication = EventApplication(
          id: application.id,
          status: 'APPROVED',
          influencer: application.influencer,
        );
        
        // Remover de pendientes y agregar a aceptadas
        pendingApplications.removeAt(applicationIndex);
        acceptedApplications.add(approvedApplication);
        
        print('✅ Aplicación aprobada exitosamente: ${application.influencer.influencerName} (App ID: ${application.id})');
        print('📊 Pendientes: ${pendingApplications.length}, Aceptadas: ${acceptedApplications.length}');
        
        return true; // Éxito
      } else {
        print('❌ Error del backend: ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error al aprobar aplicación: $e');
      return false;
    }
  }
}