import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/card_info_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/pill_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/section_title_widget.dart';

class EventContentInformationTab extends StatelessWidget {
  final Event event;

  const EventContentInformationTab({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final DateFormat dayFormat = DateFormat('EEEE d', 'es'); // Lunes 21
    final DateFormat dateFormat = DateFormat('d MMM yyyy', 'es');
    final DateFormat timeFormat = DateFormat('h:mm a', 'es');

    final String formattedDate = dateFormat.format(event.eventDetailsStartDateEvent);
    final String dayAndDate = dayFormat.format(event.eventDetailsStartDateEvent);
    final String timeRange = 
        'de ${timeFormat.format(event.eventDetailsStartDateEvent)} - ${timeFormat.format(event.eventDetailsEndDateEvent)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección "Acerca de"
          const SectionTitleWidget(title: 'Acerca de'),
          const SizedBox(height: 16),
          Text(
            event.eventDescription,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Sección "Detalles del evento"
          const SectionTitleWidget(title: 'Detalles del evento'),
          const SizedBox(height: 16),
          
          // Fecha y hora
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.red[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayAndDate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeRange,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sección "Tipo de publicidad"
          const SectionTitleWidget(title: 'Tipo de publicidad'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PillWidget(text: event.eventDetailsKindOfPublicity),
                const SizedBox(height: 8),
                Text(
                  'Publicidad que se puede realizar desde cualquier lugar (no requiere la presencia física del influencer).',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sección "Trabajo a realizar"
          const SectionTitleWidget(title: 'Trabajo a realizar'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Requisitos como bullet points
                _buildBulletPoint(event.jobDetailsJobToDo),
                // Puedes agregar más requisitos si los tienes en el modelo
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sección "Monto por persona"
          if (event.jobDetailsShowPayment) ...[
            const SectionTitleWidget(title: 'Monto por persona'),
            const SizedBox(height: 16),
            CardInfoWidget(
              title: 'Pago',
              subtitle: "${event.jobDetailsPayFare} soles",
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 24),
          ],

          // Sección "Ubicación"
          if (event.address != null && event.address!.isNotEmpty) ...[
            const SectionTitleWidget(title: 'Ubicación'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.address!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Placeholder para el mapa (si tienes coordenadas)
            if (event.latitude != null && event.longitude != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mapa del evento',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
