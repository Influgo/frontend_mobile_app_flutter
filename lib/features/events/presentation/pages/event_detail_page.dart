import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('EEEE d MMM yyyy', 'es');
    final DateFormat timeFormat = DateFormat('h:mma', 'es');

    final String formattedDate =
        dateFormat.format(event.eventDetailsStartDateEvent);
    final String formattedTimeRange =
        '${timeFormat.format(event.eventDetailsStartDateEvent)} – ${timeFormat.format(event.eventDetailsEndDateEvent)}';

    final String imageUrl = event.s3File?.url ??
        'https://cdn.pixabay.com/photo/2024/11/25/10/38/mountains-9223041_1280.jpg';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Evento'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen superior
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Nombre del evento
            Text(
              event.eventName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),
            Text(
              '$formattedDate – en 1 semana',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _pill("evento virtual"),

            const SizedBox(height: 24),
            _sectionTitle("Acerca de"),
            Text(
              event.eventDescription,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 24),
            _sectionTitle("Detalles del evento"),
            Text(
              '$formattedDate de $formattedTimeRange',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 24),
            _sectionTitle("Tipo de publicidad"),
            _cardInfo(
              "Publicidad virtual",
              "Publicidad que se puede realizar desde cualquier lugar (no requiere la presencia física del influencer).",
            ),

            const SizedBox(height: 24),
            _sectionTitle("Trabajo a realizar"),
            const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• Requisito 1"),
                  Text("• Requisito 2"),
                  Text("• Requisito 3"),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle("Monto por persona"),
            Text(
              "${event.jobDetailsPayFare} soles",
              style: const TextStyle(fontSize: 14),
            ),

            /*const SizedBox(height: 24),
            _sectionTitle("Ubicación"),
            Text(
              event.eventLocation ?? 'Ubicación no especificada',
              style: const TextStyle(fontSize: 14),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _cardInfo(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff3f4f6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.purple, fontSize: 12),
      ),
    );
  }
}
