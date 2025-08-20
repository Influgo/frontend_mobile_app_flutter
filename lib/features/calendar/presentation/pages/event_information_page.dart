import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/presentation/widgets/event_content_information_tab.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_tab_item.dart';
import 'package:intl/intl.dart';

class EventInformationPage extends StatefulWidget {
  final Event event;

  const EventInformationPage({Key? key, required this.event}) : super(key: key);
  
  @override
  _EventInformationPageState createState() => _EventInformationPageState();
}

class _EventInformationPageState extends State<EventInformationPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dayFormat = DateFormat('EEEE d', 'es'); // Lunes 21
    final DateFormat dateFormat = DateFormat('d MMM yyyy', 'es');
    final DateFormat timeFormat = DateFormat('h:mm a', 'es');

    final String formattedDate =
        dateFormat.format(widget.event.eventDetailsStartDateEvent);
    final String formattedDayDate =
        dayFormat.format(widget.event.eventDetailsStartDateEvent);
    final String formattedTimeRange =
        'de ${timeFormat.format(widget.event.eventDetailsStartDateEvent)} - ${timeFormat.format(widget.event.eventDetailsEndDateEvent)}';
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
                        title: 'Postulaciones',
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
                    EventContentInformationTab(event: widget.event),
                    
                    // Tab 2: Postulaciones (placeholder por ahora)
                    const Center(
                      child: Text(
                        'Postulaciones\n(En desarrollo)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    // Tab 3: Participantes (placeholder por ahora)
                    const Center(
                      child: Text(
                        'Participantes\n(En desarrollo)',
                        textAlign: TextAlign.center,
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