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
    return MediaFile(
      url: json['tempUrl'] ?? json['url'],
      expired: json['expired'] ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'])
          : null,
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
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        id: json['id'] ?? 0,
        s3File:
            json['s3File'] != null ? MediaFile.fromJson(json['s3File']) : null,
        eventName: json['eventName'] ?? 'Evento sin nombre',
        eventDescription: json['eventDescription'] ?? 'Sin descripción',
        eventDetailsStartDateEvent:
            DateTime.tryParse(json['eventDetailsStartDateEvent'] ?? '') ??
                DateTime.now(),
        eventDetailsEndDateEvent:
            DateTime.tryParse(json['eventDetailsEndDateEvent'] ?? '') ??
                DateTime.now(),
        eventDetailsKindOfPublicity:
            json['eventDetailsKindOfPublicity'] ?? 'N/A',
        jobDetailsJobToDo: json['jobDetailsJobToDo'] ?? 'N/A',
        jobDetailsPayFare: (json['jobDetailsPayFare'] ?? 0).toDouble(),
        jobDetailsShowPayment: json['jobDetailsShowPayment'] ?? false,
        jobDetailsQuantityOfPeople: json['jobDetailsQuantityOfPeople'] ?? 0,
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
