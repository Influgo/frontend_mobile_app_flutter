import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/presentation/widgets/tab_event_content_applicators.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/presentation/widgets/tab_event_content_accepted.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/data/models/extended_event_model.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/presentation/widgets/tab_event_content_information.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_tab_item.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EventInformationPage extends StatefulWidget {
  final Event event;

  const EventInformationPage({Key? key, required this.event}) : super(key: key);
  
  @override
  _EventInformationPageState createState() => _EventInformationPageState();
}

class _EventInformationPageState extends State<EventInformationPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ExtendedEvent? _extendedEvent;
  bool _isLoadingApplications = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadEventApplications();
  }

  Future<void> _loadEventApplications() async {
    setState(() {
      _isLoadingApplications = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        _createEmptyExtendedEvent();
        return;
      }

      // Obtener entrepreneur ID
      final entrepreneurId = await _getEntrepreneurId();
      if (entrepreneurId == null) {
        _createEmptyExtendedEvent();
        return;
      }

      // Llamar al endpoint para obtener eventos con aplicaciones
      final eventDate = widget.event.eventDetailsStartDateEvent;
      final response = await http.get(
        Uri.parse('https://influyo-testing.ryzeon.me/api/v1/entities/events/schedule/month?entrepreneurId=$entrepreneurId&year=${eventDate.year}&month=${eventDate.month}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> eventsData = json.decode(response.body);
        
        // Buscar el evento actual en la respuesta
        final eventData = eventsData.firstWhere(
          (data) => data['event']['id'] == widget.event.id,
          orElse: () => null,
        );

        if (eventData != null) {
          setState(() {
            _extendedEvent = ExtendedEvent.fromJson(eventData);
            _isLoadingApplications = false;
          });
        } else {
          _createEmptyExtendedEvent();
        }
      } else {
        _createEmptyExtendedEvent();
      }
    } catch (e) {
      print('Error loading event applications: $e');
      _createEmptyExtendedEvent();
    }
  }

  Future<int?> _getEntrepreneurId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('https://influyo-testing.ryzeon.me/api/v1/entities/entrepreneur/self'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'] as int?;
      }
    } catch (e) {
      print('Error getting entrepreneur ID: $e');
    }
    return null;
  }

  void _createEmptyExtendedEvent() {
    setState(() {
      _extendedEvent = ExtendedEvent(
        event: widget.event,
        pendingApplications: [],
        acceptedApplications: [],
      );
      _isLoadingApplications = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('d MMM yyyy', 'es');

    final String formattedDate =
        dateFormat.format(widget.event.eventDetailsStartDateEvent);
    final String defaultImageUrl =
        'https://cdn.pixabay.com/photo/2024/11/25/10/38/mountains-9223041_1280.jpg';

    final String imageUrl = (widget.event.s3File?.isUrlValid == true)
        ? widget.event.s3File!.url!
        : defaultImageUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Column(
            children: [
              // Hero Section con imagen
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Información básica del evento
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.eventName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$formattedDate – en 1 semana',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    //const SizedBox(height: 4),
                    /*Text(
                      'Hora: ${DateFormat('h:mm a', 'es').format(widget.event.eventDetailsStartDateEvent)} - ${DateFormat('h:mm a', 'es').format(widget.event.eventDetailsEndDateEvent)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    */
                  ],
                ),
              ),
              
              // TabBar con estilo similar al ExploraPage
              Column(
                children: [
                  TabBar(
                    dividerColor: Colors.transparent,
                    dividerHeight: 0,
                    controller: _tabController,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: Colors.transparent,
                    tabs: [
                      CustomTabItem(
                        title: 'Información',
                        index: 0,
                        tabController: _tabController,
                      ),
                      CustomTabItem(
                        title: _isLoadingApplications ? 'Postulaciones...' : 'Postulaciones',
                        index: 1,
                        tabController: _tabController,
                      ),
                      CustomTabItem(
                        title: 'Participantes',
                        index: 2,
                        tabController: _tabController,
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -12.0),
                    child: Stack(
                      children: [
                        Container(
                          height: 2,
                          color: Colors.grey[300],
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double tabWidth = constraints.maxWidth / 3;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.only(
                                  left: _tabController.index * tabWidth),
                              width: tabWidth,
                              height: 2,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFC20B0C),
                                    Color(0xFF7E0F9D),
                                    Color(0xFF2616C7)
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Información del evento
                    TabEventContentInformation(event: widget.event),

                    // Tab 2: Postulaciones
                    _isLoadingApplications
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _extendedEvent != null
                            ? TabEventContentApplicators(
                                extendedEvent: _extendedEvent!,
                                onContractSigned: () {
                                  // Cambiar al tab de participantes (índice 2)
                                  _tabController.animateTo(2);
                                },
                              )
                            : const Center(
                                child: Text(
                                  'Error al cargar las aplicaciones',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                    // Tab 3: Participantes
                    _isLoadingApplications
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _extendedEvent != null
                            ? TabEventContentAccepted(
                                extendedEvent: _extendedEvent!,
                              )
                            : const Center(
                                child: Text(
                                  'Error al cargar los colaboradores aceptados',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                  ],
                ),
              ),
            ],
          ),
          // Botón flotante de regreso (como en EventDetailPage)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}