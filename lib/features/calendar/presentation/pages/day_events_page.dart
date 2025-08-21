import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/presentation/pages/event_information_page.dart';

class DayEventsPage extends StatelessWidget {
  final DateTime selectedMonth;
  final Map<DateTime, List<Event>> monthEvents;

  const DayEventsPage({
    super.key,
    required this.selectedMonth,
    required this.monthEvents,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat monthFormat = DateFormat('MMMM', 'es');
    final String formattedMonth = monthFormat.format(selectedMonth);
    
    // Debug: Imprimir información de los eventos recibidos
    print('📋 DayEventsPage: Received month events for ${selectedMonth.year}/${selectedMonth.month}');
    print('📋 DayEventsPage: Total days with events: ${monthEvents.length}');
    monthEvents.forEach((date, eventList) {
      print('📋 DayEventsPage: Date ${date.day}/${date.month}/${date.year} has ${eventList.length} events');
      eventList.forEach((event) {
        print('📋 DayEventsPage: - Event: ${event.eventName}');
      });
    });
    
    // Crear lista ordenada de fechas con eventos
    final sortedDates = monthEvents.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0, // Mantiene la elevación en 0 al hacer scroll
        backgroundColor: const Color(0xFFF9F9F9),
        surfaceTintColor: const Color(0xFFF9F9F9), // Color cuando se hace scroll
        foregroundColor: Colors.black, // Color de los iconos y texto
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFF9F9F9), // Color de la barra de estado
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calendario',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context); // Volver a calendar_page
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SvgPicture.asset(
                'assets/icons/calendarview.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF9F9F9), // Mismo color que el AppBar
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Título del mes
            Text(
              formattedMonth.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Lista de eventos por fecha
            Expanded(
              child: sortedDates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay eventos para este mes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: sortedDates.length,
                      itemBuilder: (context, index) {
                        final date = sortedDates[index];
                        final events = monthEvents[date]!;
                        
                        return _buildDateSection(date, events);
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildDateSection(DateTime date, List<Event> events) {
    final DateFormat dayFormat = DateFormat('EEEE', 'es');
    final DateFormat dateFormat = DateFormat('d MMM', 'es');
    
    final String dayName = dayFormat.format(date);
    final String formattedDate = dateFormat.format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de la fecha
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '$dayName, $formattedDate',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        // Lista de eventos para esta fecha
        ...events.map((event) => _buildEventCard(event)).toList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEventCard(Event event) {
    final DateFormat timeFormat = DateFormat('h:mma', 'es');
    final String startTime = timeFormat.format(event.eventDetailsStartDateEvent);
    final String endTime = timeFormat.format(event.eventDetailsEndDateEvent);

    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventInformationPage(event: event),
              ),
            );
          },
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Barra de color lateral integrada al inicio
                Container(
                  width: 5,
                  height: 85, // Altura para cubrir todo el card
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFC20B0C),
                        Color(0xFF7E0F9D),
                        Color(0xFF2616C7),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                // Información del evento con padding interno
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Columna izquierda: Nombre y participantes
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nombre del evento
                            Text(
                              event.eventName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Participantes
                            _buildParticipants(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Columna derecha: Horas
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            startTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            endTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      /*
                      // Columna derecha: Imagen del evento
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: event.s3File != null && event.s3File!.isUrlValid
                              ? Image.network(
                                  event.s3File!.url!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: 25,
                                      ),
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 25,
                                ),
                        ),
                      ),
                      */
                    ],
                  ),
                ),
                ),
                const SizedBox(width: 8),

                /*
                // Ícono de flecha
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
                */
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticipants() {
    // Mock de participantes para el ejemplo
    final List<String> participantAvatars = [
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      'https://images.unsplash.com/photo-1494790108755-2616b612b5e5?w=150&h=150&fit=crop&crop=face',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
    ];

    return Row(
      children: participantAvatars.asMap().entries.map((entry) {
        int index = entry.key;
        String avatarUrl = entry.value;
        
        return Container(
          margin: EdgeInsets.only(right: index < participantAvatars.length - 1 ? 6 : 0),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            image: DecorationImage(
              image: NetworkImage(avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }
}
