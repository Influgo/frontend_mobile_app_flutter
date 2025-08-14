import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/card_info_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/pill_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/section_title_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/pages/application_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {

  bool _isLoading = true;
  String? _errorMessage;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
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
          SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 174,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.eventName,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '$formattedDate – en 1 semana',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          PillWidget("evento virtual"),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SectionTitleWidget("Acerca de"),
                      Text(
                        widget.event.eventDescription,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      SectionTitleWidget("Detalles del evento"),
                      Text(
                        '$formattedDayDate $formattedTimeRange',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      SectionTitleWidget("Tipo de publicidad"),
                      CardInfoWidget(
                        title: "Publicidad virtual",
                        subtitle:
                            "Publicidad que se puede realizar desde cualquier lugar (no requiere la presencia física del influencer).",
                      ),
                      const SizedBox(height: 24),
                      SectionTitleWidget("Trabajo a realizar"),
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
                      SectionTitleWidget("Monto por persona"),
                      Text(
                        "${widget.event.jobDetailsPayFare} soles",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      SectionTitleWidget("Ubicación"),
                      if (widget.event.address.isEmpty || widget.event.address == 'Sin dirección')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 18, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "Jr. Enrique Barreda 234 Urb Las Palmeras, La Molina, Lima- Perú",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 18, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.event.address,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (_userRole?.toUpperCase() == 'INFLUENCER')
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ApplicationPage(event: widget.event),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              'Postular',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                  child:
                      Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
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
