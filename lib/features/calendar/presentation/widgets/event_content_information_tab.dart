import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/card_info_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/section_title_widget.dart';

class EventContentInformationTab extends StatelessWidget {
  final Event event;

  const EventContentInformationTab({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final DateFormat dayFormat = DateFormat('EEEE d', 'es'); // Lunes 21
    final DateFormat timeFormat = DateFormat('h:mm a', 'es');

    final String formattedDayDate =
        dayFormat.format(event.eventDetailsStartDateEvent);
    final String formattedTimeRange =
        'de ${timeFormat.format(event.eventDetailsStartDateEvent)} - ${timeFormat.format(event.eventDetailsEndDateEvent)}';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección "Acerca de"
          SectionTitleWidget("Acerca de"),
          Text(
            event.eventDescription,
            style: const TextStyle(fontSize: 14),
          ),

          // Sección "Detalles del evento"
          const SizedBox(height: 24),
          SectionTitleWidget("Detalles del evento"),
          Text(
            '$formattedDayDate $formattedTimeRange',
             style: const TextStyle(fontSize: 14),
          ),

          // Sección "Tipo de publicidad"
          const SizedBox(height: 24),
        
          const SectionTitleWidget('Tipo de publicidad'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              border: Border.all(
                color: const Color(0xFFF2F2F7),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPublicityTypeTitle(event.eventDetailsKindOfPublicity),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPublicityTypeSubtitle(event.eventDetailsKindOfPublicity),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          
          // Sección "Trabajo a realizar"
          const SizedBox(height: 24),
          SectionTitleWidget('Trabajo a realizar'),
          Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Requisitos como bullet points
                _buildBulletPoint(event.jobDetailsJobToDo),
                // Puedes agregar más requisitos si los tienes en el modelo
              ],
            ),
          ),

          // Sección "Monto por persona"
          const SizedBox(height: 24),
          SectionTitleWidget("Monto por persona"),
          Text(
            "${event.jobDetailsPayFare} soles",
            style: const TextStyle(fontSize: 14),
          ),

          // Sección "Ubicación"
          const SizedBox(height: 24),
          if (event.address.isNotEmpty) ...[
            SectionTitleWidget('Ubicación'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
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
                      event.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getPublicityTypeTitle(String publicityType) {
    
    // Normalizar el texto para comparaciones más flexibles
    final normalized = publicityType.toLowerCase().trim();
    
    if (normalized.contains('presencial')) {
      return 'Publicidad presencial';
    } else if (normalized.contains('virtual')) {
      return 'Publicidad virtual';
    } else {
      // Mantener el texto original si no coincide con los patrones conocidos
      return publicityType;
    }
  }

  String _getPublicityTypeSubtitle(String publicityType) {
    // Normalizar el texto para comparaciones más flexibles
    final normalized = publicityType.toLowerCase().trim();
    
    if (normalized.contains('presencial')) {
      return 'Publicidad que requiere que el influencer se dirija al lugar indicado.';
    } else if (normalized.contains('virtual')) {
      return 'Publicidad que se puede realizar desde cualquier lugar (no requiere la presencia física del influencer).';
    } else {
      // Para tipos personalizados, mostrar una descripción genérica más útil
      return 'Consulta los detalles específicos de este tipo de publicidad.';
    }
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
