import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_mobile_app_flutter/features/events/domain/repositories/event_repository_impl.dart';
import 'package:frontend_mobile_app_flutter/features/events/domain/usecases/get_events_usecase.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/event_card_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/services/event_service.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/horizontal_event_cards_section.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/custom_fab_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/scrollable_filters_events.dart';
import 'package:frontend_mobile_app_flutter/core/constants/filter_constants.dart';

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
  String? _accountStatus; // Para almacenar el estado de verificación del usuario

  // Filtros básicos y avanzados
  String _selectedCategory = "Todos";
  List<String> _advancedSelectedCategories = [];
  String _selectedLocation = "Todos";
  String _selectedEventType = "Todos";

  // Categorías para eventos
  List<String> _categories = ["Todos", ...FilterConstants.categories];

  // Listas pre-procesadas para la UI
  List<Event> _highestPayingEvents = [];
  List<Event> _mostRecentEvents = [];
  List<Event> _mostRequestedEvents = [];

  @override
  void initState() {
    super.initState();
    // Instanciamos el use case aquí, asegurando que el servicio se crea una vez.
    _useCase = GetEventsUseCase(EventRepositoryImpl(EventService()));
    _loadUserData();
    _fetchEvents();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserRole = prefs.getString('userRole');
      final userId = prefs.getString('userId');
      final token = prefs.getString('token');

      setState(() {
        _userRole = storedUserRole;
      });

      // Obtener el estado de verificación del usuario si tenemos userId y token
      if (userId != null && token != null) {
        await _loadAccountStatus(userId, token);
      }
    } catch (e) {
      debugPrint('Error al cargar datos del usuario: $e');
    }
  }

  Future<void> _loadAccountStatus(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://influyo-testing.ryzeon.me/api/v1/account/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final accountStatus = data['userDto']?['accountStatus'];
        setState(() {
          _accountStatus = accountStatus;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar estado de cuenta: $e');
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

  // Método para obtener eventos filtrados
  List<Event> _getFilteredEvents() {
    List<Event> filtered = _allEvents;

    // Filtrar por categoría básica (solo si no hay filtros avanzados activos)
    if (_selectedCategory != "Todos" && !_hasAdvancedFiltersActive()) {
      // Nota: Como no hay campo de categoría en el modelo Event actual,
      // este filtro es solo visual por ahora
      // filtered = filtered.where((e) => e.category == _selectedCategory).toList();
    }

    // Filtrar por categorías avanzadas
    if (_advancedSelectedCategories.isNotEmpty) {
      // Nota: Como no hay campo de categoría en el modelo Event actual,
      // este filtro es solo visual por ahora
      // filtered = filtered.where((e) => _advancedSelectedCategories.contains(e.category)).toList();
    }

    // Filtrar por ubicación
    if (_selectedLocation != "Todos") {
      // Nota: Como no hay campo de ubicación en el modelo Event actual,
      // este filtro es solo visual por ahora
      // filtered = filtered.where((e) => e.location == _selectedLocation).toList();
    }

    // Filtrar por tipo de evento
    if (_selectedEventType != "Todos") {
      // Nota: Como no hay campo de tipo de evento en el modelo Event actual,
      // este filtro es solo visual por ahora
      // filtered = filtered.where((e) => e.eventType == _selectedEventType).toList();
    }

    return filtered;
  }

  bool _hasAdvancedFiltersActive() {
    return _advancedSelectedCategories.isNotEmpty ||
        _selectedLocation != "Todos" ||
        _selectedEventType != "Todos";
  }

  // Nuevo método para procesar y preparar las listas para mostrar
  void _processEventsForDisplay() {
    final filteredEvents = _getFilteredEvents();

    if (filteredEvents.isEmpty) {
      _highestPayingEvents = [];
      _mostRecentEvents = [];
      _mostRequestedEvents = [];
      return;
    }

    // Procesar "Más recientes"
    final recentEvents = List<Event>.from(filteredEvents)
      ..sort((a, b) =>
          b.eventDetailsStartDateEvent.compareTo(a.eventDetailsStartDateEvent));
    _mostRecentEvents = recentEvents.take(5).toList();

    // Procesar "Mejor remunerados"
    final bestPaid = List<Event>.from(filteredEvents)
      ..sort((a, b) => b.jobDetailsPayFare.compareTo(a.jobDetailsPayFare));
    _highestPayingEvents = bestPaid.take(5).toList();

    // Procesar "Más solicitados"
    final mostDemanded = List<Event>.from(filteredEvents)
      ..sort((a, b) =>
          b.jobDetailsQuantityOfPeople.compareTo(a.jobDetailsQuantityOfPeople));
    _mostRequestedEvents = mostDemanded.take(5).toList();
  }

  void _onAdvancedFiltersApplied(
      List<String> categories, String location, String eventType) {
    setState(() {
      _advancedSelectedCategories = categories;
      _selectedLocation = location;
      _selectedEventType = eventType;
      
      if (_hasAdvancedFiltersActive()) {
        _selectedCategory = "Todos";
      }
      _processEventsForDisplay();
    });
  }

  void _onCategorySelected(String newCategory) {
    setState(() {
      _selectedCategory = newCategory;
      
      if (newCategory != "Todos") {
        _advancedSelectedCategories = [];
        _selectedLocation = "Todos";
        _selectedEventType = "Todos";
      }
      _processEventsForDisplay();
    });
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
      body: Column(
        children: [
          ScrollableFiltersEvents(
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
            categories: _categories,
            onAdvancedFiltersApplied: _onAdvancedFiltersApplied,
            selectedCategories: _advancedSelectedCategories,
            selectedLocation: _selectedLocation,
            selectedEventType: _selectedEventType,
          ),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: _userRole?.toUpperCase() == 'ENTREPRENEUR' && 
                             _accountStatus?.toUpperCase() == 'ACTIVE'
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

    final filteredEvents = _getFilteredEvents();

    // Las listas ya están procesadas y listas para usar
    return RefreshIndicator(
      onRefresh: _fetchEvents,
      child: ListView(
        padding: const EdgeInsets.only(top: 16, left: 2, right: 2),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (filteredEvents.isEmpty && (_hasAdvancedFiltersActive() || _selectedCategory != "Todos"))
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Ups...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No encontramos eventos que coincidan con tus criterios de búsqueda. Prueba con otros.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _clearAllFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Limpiar filtros'),
                  ),
                ],
              ),
            )
          else ...[
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
          ],
          // Considera un padding inferior para que el FAB no oculte contenido
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = "Todos";
      _advancedSelectedCategories = [];
      _selectedLocation = "Todos";
      _selectedEventType = "Todos";
      _processEventsForDisplay();
    });
  }
}


