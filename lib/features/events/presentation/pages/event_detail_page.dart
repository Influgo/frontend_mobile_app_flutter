import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/card_info_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/pill_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/section_title_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/pages/application_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {

  bool _isLoading = false;
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

  Future<int?> _getInfluencerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('https://influyo-testing.ryzeon.me/api/v1/entities/influencer/self'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'] as int?;
      }
    } catch (e) {
      print('Error getting influencer ID: $e');
    }
    return null;
  }

  Future<void> _applyToEvent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        setState(() {
          _errorMessage = 'Token de autenticación no encontrado';
          _isLoading = false;
        });
        return;
      }

      // Obtener el influencerId
      final influencerId = await _getInfluencerId();
      if (influencerId == null) {
        setState(() {
          _errorMessage = 'No se pudo obtener el ID del influencer';
          _isLoading = false;
        });
        return;
      }

      final body = {
        "influencerId": influencerId,
        "eventId": widget.event.id,
      };

      final response = await http.post(
        Uri.parse('https://influyo-testing.ryzeon.me/api/v1/entities/event-applications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Navegar a la página de éxito
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ApplicationPage(event: widget.event),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Error al enviar postulación: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                        Column(
                          children: [
                            if (_errorMessage != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _applyToEvent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Postular',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                            ),
                          ],
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
