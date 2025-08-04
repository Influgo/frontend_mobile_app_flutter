import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_mobile_app_flutter/features/events/domain/repositories/event_repository_impl.dart';
import 'package:frontend_mobile_app_flutter/features/events/domain/usecases/get_events_usecase.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/event_card_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/services/event_service.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/horizontal_event_cards_section.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/custom_fab_widget.dart';

// class EventsPage extends StatefulWidget {
//   const EventsPage({super.key});
//
//   @override
//   _EventsPageState createState() => _EventsPageState();
// }
//
// class _EventsPageState extends State<EventsPage> {
//   final EventService _service = EventService();
//   bool _isLoading = true;
//   String? _errorMessage;
//   List<Event> _events = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchEvents();
//   }
//
//   final _useCase = GetEventsUseCase(EventRepositoryImpl(EventService()));
//
//   Future<void> _fetchEvents() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final events = await _useCase();
//       setState(() {
//         _events = events;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error al cargar los eventos: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: Row(
//           children: [
//             Expanded(
//               child: Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Buscar',
//                     border: InputBorder.none,
//                     prefixIcon: Icon(Icons.search),
//                     contentPadding: EdgeInsets.symmetric(vertical: 10),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 12),
//             IconButton(
//               icon: Icon(Icons.notifications_outlined),
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ),
//       body: _buildContent(),
//       floatingActionButton: CustomFAB(
//         onPressed: () {
//           Navigator.pushNamed(context, '/add-event');
//         },
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
//
//   Widget _buildContent() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (_errorMessage != null) {
//       return Center(child: Text(_errorMessage!));
//     }
//
//     if (_events.isEmpty) {
//       return Center(child: Text("No se encontraron eventos"));
//     }
//
//     final recentEvents = List<Event>.from(_events)
//       ..sort((a, b) =>
//           b.eventDetailsStartDateEvent.compareTo(a.eventDetailsStartDateEvent));
//
//     final mostRecent = recentEvents.take(5).toList();
//
//     final bestPaid = List<Event>.from(_events)
//       ..sort((a, b) => b.jobDetailsPayFare.compareTo(a.jobDetailsPayFare));
//
//     final highestPaying = bestPaid.take(5).toList();
//
//     final mostDemanded = List<Event>.from(_events)
//       ..sort((a, b) =>
//           b.jobDetailsQuantityOfPeople.compareTo(a.jobDetailsQuantityOfPeople));
//
//     final mostRequestedEvents = mostDemanded.take(5).toList();
//
//     return RefreshIndicator(
//       onRefresh: _fetchEvents,
//       child: ListView(
//         padding: const EdgeInsets.only(top: 16, left: 2, right: 2),
//         physics: const AlwaysScrollableScrollPhysics(),
//         children: [
//           if (highestPaying.isNotEmpty)
//             Align(
//               alignment: Alignment.topLeft,
//               child: HorizontalEventCardsSection(
//                 title: "Mejor remunerados",
//                 cards: highestPaying
//                     .map((e) => EventCardWidget(event: e))
//                     .toList(),
//               ),
//             ),
//           const SizedBox(height: 16),
//           if (mostRecent.isNotEmpty)
//             Align(
//               alignment: Alignment.topLeft,
//               child: HorizontalEventCardsSection(
//                 title: "Más recientes",
//                 cards:
//                     mostRecent.map((e) => EventCardWidget(event: e)).toList(),
//               ),
//             ),
//           const SizedBox(height: 16),
//           if (mostRequestedEvents.isNotEmpty)
//             Align(
//               alignment: Alignment.topLeft,
//               child: HorizontalEventCardsSection(
//                 title: "Más solicitados",
//                 cards: mostRequestedEvents
//                     .map((e) => EventCardWidget(event: e))
//                     .toList(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }


class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  // El EventService ahora solo se instancia una vez, dentro del UseCase
  late final GetEventsUseCase _useCase;

  bool _isLoading = true;
  String? _errorMessage;
  List<Event> _allEvents = []; // Almacena todos los eventos originales
  String? _userRole; // Para almacenar el rol del usuario

  // Listas pre-procesadas para la UI
  List<Event> _highestPayingEvents = [];
  List<Event> _mostRecentEvents = [];
  List<Event> _mostRequestedEvents = [];

  @override
  void initState() {
    super.initState();
    // Instanciamos el use case aquí, asegurando que el servicio se crea una vez.
    _useCase = GetEventsUseCase(EventRepositoryImpl(EventService()));
    _loadUserRole();
    _fetchEvents();
  }

  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserRole = prefs.getString('userRole');
      setState(() {
        _userRole = storedUserRole;
      });
    } catch (e) {
      debugPrint('Error al cargar rol del usuario: $e');
    }
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      // Opcional: Limpiar listas antiguas mientras se carga
      _highestPayingEvents = [];
      _mostRecentEvents = [];
      _mostRequestedEvents = [];
    });

    try {
      final events = await _useCase();
      _allEvents = events; // Guardamos la lista original
      _processEventsForDisplay(); // Procesamos los datos para la UI

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los eventos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Nuevo método para procesar y preparar las listas para mostrar
  void _processEventsForDisplay() {
    if (_allEvents.isEmpty) {
      _highestPayingEvents = [];
      _mostRecentEvents = [];
      _mostRequestedEvents = [];
      return;
    }

    // Procesar "Más recientes"
    final recentEvents = List<Event>.from(_allEvents)
      ..sort((a, b) =>
          b.eventDetailsStartDateEvent.compareTo(a.eventDetailsStartDateEvent));
    _mostRecentEvents = recentEvents.take(5).toList();

    // Procesar "Mejor remunerados"
    final bestPaid = List<Event>.from(_allEvents)
      ..sort((a, b) => b.jobDetailsPayFare.compareTo(a.jobDetailsPayFare));
    _highestPayingEvents = bestPaid.take(5).toList();

    // Procesar "Más solicitados"
    final mostDemanded = List<Event>.from(_allEvents)
      ..sort((a, b) =>
          b.jobDetailsQuantityOfPeople.compareTo(a.jobDetailsQuantityOfPeople));
    _mostRequestedEvents = mostDemanded.take(5).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField( // Usar const si no cambia
                  decoration: InputDecoration(
                    hintText: 'Buscar',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12), // Usar const
            IconButton(
              icon: const Icon(Icons.notifications_outlined), // Usar const
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: _buildContent(),
      floatingActionButton: _userRole?.toUpperCase() == 'ENTREPRENEUR' 
        ? CustomFAB(
            onPressed: () {
              Navigator.pushNamed(context, '/add-event');
            },
          )
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    // Ahora usamos _allEvents para la comprobación de vacío general
    if (_allEvents.isEmpty) {
      return const Center(child: Text("No se encontraron eventos"));
    }

    // Las listas ya están procesadas y listas para usar
    return RefreshIndicator(
      onRefresh: _fetchEvents,
      child: ListView(
        padding: const EdgeInsets.only(top: 16, left: 2, right: 2),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (_highestPayingEvents.isNotEmpty)
            Align(
              alignment: Alignment.topLeft,
              child: HorizontalEventCardsSection(
                title: "Mejor remunerados",
                cards: _highestPayingEvents // Usar la lista pre-procesada
                    .map((e) => EventCardWidget(event: e))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (_mostRecentEvents.isNotEmpty)
            Align(
              alignment: Alignment.topLeft,
              child: HorizontalEventCardsSection(
                title: "Más recientes",
                cards: _mostRecentEvents // Usar la lista pre-procesada
                    .map((e) => EventCardWidget(event: e))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (_mostRequestedEvents.isNotEmpty)
            Align(
              alignment: Alignment.topLeft,
              child: HorizontalEventCardsSection(
                title: "Más solicitados",
                cards: _mostRequestedEvents // Usar la lista pre-procesada
                    .map((e) => EventCardWidget(event: e))
                    .toList(),
              ),
            ),
          // Considera un padding inferior para que el FAB no oculte contenido
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}


