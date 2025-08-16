import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/presentation/pages/day_events_page.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/services/event_service.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Usar eventos reales del API
  Map<DateTime, List<Event>> events = {};
  final EventService _eventService = EventService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Obtener todos los eventos (puedes ajustar el tamaño según necesites)
      final eventResponse = await _eventService.getEvents(size: 100);
      
      // Filtrar eventos solo si es emprendedor (ya que son los que crean eventos)
      List<Event> filteredEvents = eventResponse.content;
      
      // Agrupar eventos por fecha
      final Map<DateTime, List<Event>> groupedEvents = {};
      
      for (Event event in filteredEvents) {
        final eventDate = DateTime(
          event.eventDetailsStartDateEvent.year,
          event.eventDetailsStartDateEvent.month,
          event.eventDetailsStartDateEvent.day,
        );
        
        if (groupedEvents[eventDate] == null) {
          groupedEvents[eventDate] = [];
        }
        groupedEvents[eventDate]!.add(event);
      }

      setState(() {
        events = groupedEvents;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar eventos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return events[dayKey] ?? [];
  }

  Map<DateTime, List<Event>> _getEventsForMonth(DateTime month) {
    final Map<DateTime, List<Event>> monthEvents = {};
    
    events.forEach((date, eventList) {
      if (date.year == month.year && date.month == month.month) {
        monthEvents[date] = eventList;
      }
    });
    
    return monthEvents;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0, // Mantiene la elevación en 0 al hacer scroll
          backgroundColor: const Color(0xFFF9F9F9),
          surfaceTintColor: const Color(0xFFF9F9F9), // Color cuando se hace scroll
          foregroundColor: Colors.black, // Color de los iconos y texto
          toolbarHeight: 70, // Reducir altura del AppBar
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFFF9F9F9), // Color de la barra de estado
            statusBarIconBrightness: Brightness.dark,
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: const Text(
              'Calendario',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: InkWell(
                onTap: () {
                  // Obtener solo los eventos del mes actual
                  final monthEvents = _getEventsForMonth(_focusedDay);
                  
                  // Navegar a la página de eventos del mes actual
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DayEventsPage(
                        selectedMonth: _focusedDay,
                        monthEvents: monthEvents,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: SvgPicture.asset(
                    'assets/icons/listevents.svg',
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          color: const Color(0xFFF9F9F9), // Mismo color que el AppBar
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

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
        title: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: const Text(
              'Calendario',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: InkWell(
              onTap: () {
                // Obtener solo los eventos del mes actual
                final monthEvents = _getEventsForMonth(_focusedDay);
                
                // Navegar a la página de eventos del mes actual
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DayEventsPage(
                      selectedMonth: _focusedDay,
                      monthEvents: monthEvents,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SvgPicture.asset(
                  'assets/icons/listevents.svg',
                  width: 28,
                  height: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: const Color(0xFFF9F9F9),
        onRefresh: _fetchEvents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                color: Color(0xFFF9F9F9),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: TableCalendar<String>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final events = _getEventsForDay(day);
                  final hasEvents = events.isNotEmpty;
                  
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(9.0),
                        decoration: BoxDecoration(
                          gradient: hasEvents
                              ? LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFC20B0C),
                                    Color(0xFF7E0F9D),
                                    Color(0xFF2616C7),
                                  ],
                                )
                              : null,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: hasEvents ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // Marcador azul en la parte blanca debajo del círculo
                      if (hasEvents)
                        Positioned(
                          bottom: 0, // Posicionado en la parte inferior de la celda
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 5.5,
                              height: 5.5,
                              decoration: BoxDecoration(
                                color: Color(0xFF006BFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final events = _getEventsForDay(day);
                  final hasEvents = events.isNotEmpty;
                  
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(9.0),
                        decoration: BoxDecoration(
                          gradient: hasEvents
                              ? LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFC20B0C),
                                    Color(0xFF7E0F9D),
                                    Color(0xFF2616C7),
                                  ],
                                )
                              : null,
                          color: hasEvents ? null : Colors.grey.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // Marcador azul en la parte blanca debajo del círculo
                      if (hasEvents)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 5.5,
                              height: 5.5,
                              decoration: BoxDecoration(
                                color: Color(0xFF006BFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final events = _getEventsForDay(day);
                  final hasEvents = events.isNotEmpty;
                  
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(9.0),
                        decoration: BoxDecoration(
                          gradient: hasEvents
                              ? LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFC20B0C),
                                    Color(0xFF7E0F9D),
                                    Color(0xFF2616C7),
                                  ],
                                )
                              : null,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: hasEvents ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // Marcador azul en la parte blanca debajo del círculo
                      if (hasEvents)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 5.5,
                              height: 5.5,
                              decoration: BoxDecoration(
                                color: Color(0xFF006BFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(color: Colors.black),
                holidayTextStyle: const TextStyle(color: Colors.black),
                // Espaciado y tamaños
                cellMargin: const EdgeInsets.all(15.0),
                cellPadding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0), // Más padding vertical
                defaultTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.black),
                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.black),
                titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                // Ocultar los botones de formato
                headerPadding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14, // Tamaño optimizado para mostrar Mon, Tue, Wed completos
                ),
                weekendStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14, // Tamaño optimizado para mostrar Mon, Tue, Wed completos
                ),
                //decoration: BoxDecoration(),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  
                  // Si el día tiene eventos, navegar a la página de eventos del mes
                  final dayEvents = _getEventsForDay(selectedDay);
                  if (dayEvents.isNotEmpty) {
                    // Filtrar eventos del mes del día seleccionado
                    final selectedMonth = DateTime(selectedDay.year, selectedDay.month);
                    final monthEvents = <DateTime, List<Event>>{};
                    
                    events.forEach((date, eventList) {
                      if (date.year == selectedDay.year && date.month == selectedDay.month) {
                        monthEvents[date] = eventList;
                      }
                    });
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DayEventsPage(
                          selectedMonth: selectedMonth,
                          monthEvents: monthEvents,
                        ),
                      ),
                    );
                  }
                }
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF9F9F9), // Mismo color que el fondo
              borderRadius: BorderRadius.circular(12),
            ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getMonthName(DateTime(_focusedDay.year, _focusedDay.month + 1).month)} ${DateTime(_focusedDay.year, _focusedDay.month + 1).year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNextMonthPreview(),
                ],
              ),
            ),
          const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }  Widget _buildNextMonthPreview() {
    final nextMonth = DateTime(_focusedDay.year, _focusedDay.month + 1);
    final nextMonthEvents = <DateTime, List<Event>>{};
    
    // Filtrar eventos del siguiente mes
    events.forEach((date, eventList) {
      if (date.year == nextMonth.year && date.month == nextMonth.month) {
        nextMonthEvents[date] = eventList;
      }
    });

    return TableCalendar<String>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: nextMonth,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => false, // No mostrar día seleccionado
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final dayKey = DateTime(day.year, day.month, day.day);
          final dayEvents = nextMonthEvents[dayKey] ?? [];
          final hasEvents = dayEvents.isNotEmpty;
          
          return GestureDetector(
            onTap: hasEvents ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DayEventsPage(
                    selectedMonth: nextMonth,
                    monthEvents: nextMonthEvents,
                  ),
                ),
              );
            } : null,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(9.0),
                  decoration: BoxDecoration(
                    gradient: hasEvents
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFC20B0C),
                              Color(0xFF7E0F9D),
                              Color(0xFF2616C7),
                            ],
                          )
                        : null,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: hasEvents ? Colors.white : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Marcador azul en la parte blanca debajo del círculo
                if (hasEvents)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 5.5,
                        height: 5.5,
                        decoration: BoxDecoration(
                          color: Color(0xFF006BFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        todayBuilder: (context, day, focusedDay) {
          final dayKey = DateTime(day.year, day.month, day.day);
          final dayEvents = nextMonthEvents[dayKey] ?? [];
          final hasEvents = dayEvents.isNotEmpty;
          
          return GestureDetector(
            onTap: hasEvents ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DayEventsPage(
                    selectedMonth: nextMonth,
                    monthEvents: nextMonthEvents,
                  ),
                ),
              );
            } : null,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(9.0),
                  decoration: BoxDecoration(
                    gradient: hasEvents
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFC20B0C),
                              Color(0xFF7E0F9D),
                              Color(0xFF2616C7),
                            ],
                          )
                        : null,
                    color: hasEvents ? null : Colors.grey.withOpacity(0.5), // Color para día actual sin eventos
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: Colors.white, // Siempre blanco para el día actual
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Marcador azul en la parte blanca debajo del círculo
                if (hasEvents)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 5.5,
                        height: 5.5,
                        decoration: BoxDecoration(
                          color: Color(0xFF006BFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: const TextStyle(color: Colors.black),
        holidayTextStyle: const TextStyle(color: Colors.black),
        cellMargin: const EdgeInsets.all(12.0),
        cellPadding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0), // Más padding vertical
        defaultTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: false,
        leftChevronVisible: false, // Ocultar flechas de navegación
        rightChevronVisible: false,
        titleTextStyle: const TextStyle(
          color: Colors.transparent, // Hacer el texto transparente
          fontSize: 0, // Tamaño 0 para ocultar
          height: 0, // Altura 0
        ),
        headerPadding: EdgeInsets.zero, // Sin padding para el header
        headerMargin: EdgeInsets.zero, // Sin margin para el header
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
          fontSize: 14, // Tamaño optimizado para mostrar Mon, Tue, Wed completos
        ),
        weekendStyle: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
          fontSize: 14, // Tamaño optimizado para mostrar Mon, Tue, Wed completos
        ),
        decoration: BoxDecoration(),
      ),
      onDaySelected: null, // Desactivar selección
      onPageChanged: null, // Desactivar cambio de página
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}
