import 'package:flutter/foundation.dart';

class EventResponse {
  final List<Event> content;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalElements;
  final bool first;
  final bool last;
  final bool empty;

  EventResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalElements,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      content: (json['content'] as List)
          .map((item) => Event.fromJson(item))
          .toList(),
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      first: json['first'],
      last: json['last'],
      empty: json['empty'],
    );
  }
}

class S3File {
  final String url;

  S3File({required this.url});
}

class MediaFile {
  final String? url;
  final bool expired;
  final DateTime? expiresAt;

  MediaFile({this.url, this.expired = false, this.expiresAt});

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    DateTime? expirationDate;
    if (json['expiresAt'] != null) {
      try {
        // Intentar como int (timestamp en milisegundos)
        if (json['expiresAt'] is int) {
          expirationDate = DateTime.fromMillisecondsSinceEpoch(json['expiresAt']);
        } else if (json['expiresAt'] is String) {
          // Intentar parsear como string que contiene un número
          final timestamp = int.tryParse(json['expiresAt']);
          if (timestamp != null) {
            expirationDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
          }
        }
      } catch (e) {
        print('Error parsing expiresAt: $e');
        expirationDate = null;
      }
    }
    
    return MediaFile(
      url: json['tempUrl'] ?? json['url'],
      expired: json['expired'] ?? false,
      expiresAt: expirationDate,
    );
  }

  bool get isUrlValid {
    // Check if URL exists, is not expired according to the flag,
    // and hasn't passed its expiration date
    if (url == null) return false;
    if (expired) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }
}

class Event {
  final int id;
  final MediaFile? s3File;
  final String eventName;
  final String eventDescription;
  final DateTime eventDetailsStartDateEvent;
  final DateTime eventDetailsEndDateEvent;
  final String eventDetailsKindOfPublicity;
  final String jobDetailsJobToDo;
  final double jobDetailsPayFare;
  final bool jobDetailsShowPayment;
  final int jobDetailsQuantityOfPeople;
  final String address;

  Event({
    required this.id,
    this.s3File,
    required this.eventName,
    required this.eventDescription,
    required this.eventDetailsStartDateEvent,
    required this.eventDetailsEndDateEvent,
    required this.eventDetailsKindOfPublicity,
    required this.jobDetailsJobToDo,
    required this.jobDetailsPayFare,
    required this.jobDetailsShowPayment,
    required this.jobDetailsQuantityOfPeople,
    required this.address,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      // Determinar si es la estructura del endpoint del calendario o la estructura normal
      bool isCalendarEndpoint = json.containsKey('event') && json['event'] is Map;
      Map<String, dynamic> eventData = isCalendarEndpoint ? json['event'] : json;
      
      // Extraer fechas - priorizar estructura normal, luego anidada
      DateTime startDate;
      DateTime endDate;
      String kindOfPublicity;
      
      if (eventData.containsKey('eventDetailsStartDateEvent')) {
        // Estructura normal (crear eventos, endpoints normales)
        startDate = DateTime.tryParse(eventData['eventDetailsStartDateEvent'] ?? '') ?? DateTime.now();
        endDate = DateTime.tryParse(eventData['eventDetailsEndDateEvent'] ?? '') ?? DateTime.now();
        kindOfPublicity = eventData['eventDetailsKindOfPublicity'] ?? 'N/A';
      } else if (eventData.containsKey('eventDetails') && eventData['eventDetails'] is Map) {
        // Estructura anidada (endpoint del calendario)
        final eventDetails = eventData['eventDetails'];
        startDate = DateTime.tryParse(eventDetails['startDate'] ?? '') ?? DateTime.now();
        endDate = DateTime.tryParse(eventDetails['endDate'] ?? '') ?? DateTime.now();
        kindOfPublicity = eventDetails['kindOfPublicity'] ?? 'N/A';
      } else {
        startDate = DateTime.now();
        endDate = DateTime.now();
        kindOfPublicity = 'N/A';
      }
      
      // Extraer detalles del trabajo - priorizar estructura normal, luego anidada
      String jobToDo;
      double payFare;
      bool showPayment;
      int quantityOfPeople;
      
      if (eventData.containsKey('jobDetailsJobToDo')) {
        // Estructura normal (crear eventos, endpoints normales)
        jobToDo = eventData['jobDetailsJobToDo'] ?? 'N/A';
        payFare = (eventData['jobDetailsPayFare'] ?? 0).toDouble();
        showPayment = eventData['jobDetailsShowPayment'] ?? false;
        // Manejar conversión segura de quantityOfPeople
        var quantityValue = eventData['jobDetailsQuantityOfPeople'];
        if (quantityValue is String) {
          quantityOfPeople = int.tryParse(quantityValue) ?? 0;
        } else {
          quantityOfPeople = (quantityValue ?? 0).toInt();
        }
      } else if (eventData.containsKey('eventJobDetails') && eventData['eventJobDetails'] is Map) {
        // Estructura anidada (endpoint del calendario)
        final jobDetails = eventData['eventJobDetails'];
        jobToDo = jobDetails['jobToDo'] ?? 'N/A';
        payFare = (jobDetails['payFare'] ?? 0).toDouble();
        showPayment = jobDetails['showPayment'] ?? false;
        // Manejar conversión segura de quantityOfPeople
        var quantityValue = jobDetails['quantityOfPeople'];
        if (quantityValue is String) {
          quantityOfPeople = int.tryParse(quantityValue) ?? 0;
        } else {
          quantityOfPeople = (quantityValue ?? 0).toInt();
        }
      } else {
        jobToDo = 'N/A';
        payFare = 0.0;
        showPayment = false;
        quantityOfPeople = 0;
      }
      
      // Manejar imagen - priorizar estructura normal
      MediaFile? eventImage;
      if (eventData['s3File'] != null) {
        eventImage = MediaFile.fromJson(eventData['s3File']);
      } else if (eventData['eventImage'] != null) {
        eventImage = MediaFile.fromJson(eventData['eventImage']);
      }
      
      // Manejar conversión segura del ID
      int eventId;
      var idValue = eventData['id'];
      if (idValue is String) {
        eventId = int.tryParse(idValue) ?? 0;
      } else {
        eventId = (idValue ?? 0).toInt();
      }
      
      return Event(
        id: eventId,
        s3File: eventImage,
        eventName: eventData['eventName'] ?? 'Evento sin nombre',
        eventDescription: eventData['eventDescription'] ?? 'Sin descripción',
        eventDetailsStartDateEvent: startDate,
        eventDetailsEndDateEvent: endDate,
        eventDetailsKindOfPublicity: kindOfPublicity,
        jobDetailsJobToDo: jobToDo,
        jobDetailsPayFare: payFare,
        jobDetailsShowPayment: showPayment,
        jobDetailsQuantityOfPeople: quantityOfPeople,
        address: eventData['address'] ?? 'Sin dirección',
      );
    } catch (e) {
      debugPrint('Error parsing event: $e');
      rethrow;
    }
  }

  String getEventStatus() {
    final now = DateTime.now();
    if (now.isBefore(eventDetailsStartDateEvent)) {
      return 'Próximo';
    } else if (now.isAfter(eventDetailsEndDateEvent)) {
      return 'Finalizado';
    } else {
      return 'En curso';
    }
  }

  int getDurationInDays() {
    return eventDetailsEndDateEvent
        .difference(eventDetailsStartDateEvent)
        .inDays;
  }
}
