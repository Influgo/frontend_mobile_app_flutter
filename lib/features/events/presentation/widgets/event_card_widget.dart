import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/pages/event_detail_page.dart';

class EventCardWidget extends StatelessWidget {
  final Event event;

  const EventCardWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('es', null);

    // In EventCardWidget.build method:
    final String defaultImageUrl =
        'https://cdn.pixabay.com/photo/2024/11/25/10/38/mountains-9223041_1280.jpg';

// Use the URL only if it's valid, otherwise use the default
    final imageUrl = (event.s3File?.isUrlValid == true)
        ? event.s3File!.url!
        : defaultImageUrl;

    final DateFormat startDateFormat = DateFormat('d MMM yyyy', 'es');
    final String formattedStartDate =
        startDateFormat.format(event.eventDetailsStartDateEvent).toLowerCase();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime eventDate = DateTime(
      event.eventDetailsStartDateEvent.year,
      event.eventDetailsStartDateEvent.month,
      event.eventDetailsStartDateEvent.day,
    );

    String remainingTime;

    if (eventDate.isBefore(today)) {
      remainingTime = "en curso";
    } else if (eventDate.isAtSameMomentAs(today)) {
      remainingTime = "hoy";
    } else {
      final Duration timeUntilEvent = eventDate.difference(today);
      final int daysRemaining = timeUntilEvent.inDays;

      if (daysRemaining == 1) {
        remainingTime = "mañana";
      } else if (daysRemaining < 7) {
        remainingTime = "en $daysRemaining días";
      } else {
        final int weeksRemaining = (daysRemaining / 7).ceil();
        remainingTime =
            "en ${weeksRemaining} sem${weeksRemaining != 1 ? 's' : ''}";
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailPage(event: event),
          ),
        );
      },
      child: SizedBox(
        width: 206,
        height: 150,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    imageUrl,
                    height: 73.17,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        defaultImageUrl,
                        height: 73.17,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 85,
                left: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(19.5),
                      child: Image.network(
                        imageUrl,
                        width: 39,
                        height: 39,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            defaultImageUrl,
                            width: 39,
                            height: 39,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            event.eventName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$formattedStartDate - $remainingTime',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
