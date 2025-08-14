import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/section_title_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/remuneration_switch_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController kindOfPublicityController =
      TextEditingController();
  final TextEditingController jobToDoController = TextEditingController();
  final TextEditingController payFareController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool showPayment = false;
  bool isLoading = false;
  
  // Variable para tipo de publicidad
  String selectedPublicityType = 'presencial'; // 'presencial' o 'virtual'

  // Variables para el mapa
  GoogleMapController? mapController;
  LatLng selectedLocation =
      const LatLng(-12.0464, -77.0428); // Lima, Perú como default
  Set<Marker> markers = {};

  // Variables para Places API
  final String googleApiKey =
      "AIzaSyBWG-wCB382fWd9PodWlgN5p4C_2pXoi4g"; // Reemplazar con tu API key
  List<Prediction> addressPredictions = [];
  bool showAddressSuggestions = false;

  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _addMarker(selectedLocation);

    // Listener para autocompletado de direcciones
    addressController.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    addressController.removeListener(_onAddressChanged);
    super.dispose();
  }

  void _onAddressChanged() {
    if (addressController.text.isNotEmpty &&
        addressController.text.length > 2) {
      _getAddressPredictions(addressController.text);
    } else {
      setState(() {
        showAddressSuggestions = false;
        addressPredictions.clear();
      });
    }
  }

  Future<void> _getAddressPredictions(String input) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
          'input=${Uri.encodeComponent(input)}&'
          'key=$googleApiKey&'
          'language=es&'
          'components=country:pe'; // Limitar a Perú, puedes cambiarlo

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            addressPredictions = (data['predictions'] as List)
                .map((prediction) => Prediction.fromJson(prediction))
                .toList();
            showAddressSuggestions = true;
          });
        }
      }
    } catch (e) {
      print('Error getting address predictions: $e');
    }
  }

  Future<void> _selectAddressPrediction(Prediction prediction) async {
    setState(() {
      addressController.text = prediction.description ?? '';
      showAddressSuggestions = false;
      addressPredictions.clear();
    });

    // Obtener coordenadas de la dirección seleccionada
    await _getCoordinatesFromPlaceId(prediction.placeId ?? '');
  }

  Future<void> _getCoordinatesFromPlaceId(String placeId) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/details/json?'
          'place_id=$placeId&'
          'fields=geometry&'
          'key=$googleApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final lat = location['lat'];
          final lng = location['lng'];

          setState(() {
            selectedLocation = LatLng(lat, lng);
            _addMarker(selectedLocation);
          });

          // Mover la cámara a la nueva ubicación
          if (mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newLatLng(selectedLocation),
            );
          }
        }
      }
    } catch (e) {
      print('Error getting coordinates: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          selectedLocation = LatLng(position.latitude, position.longitude);
          _addMarker(selectedLocation);
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: position,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              selectedLocation = newPosition;
            });
          },
        ),
      );
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      selectedLocation = position;
      _addMarker(position);
    });
  }

  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _coverImage = File(pickedFile.path);
        }
      });
    }
  }

  void _showImagePickerDialog(bool isProfile) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isProfile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isProfile);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        startDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  DateTime _combineDateTime(String date, String time) {
    try {
      final dateTime = DateTime.parse(date);
      // Manejo más robusto del tiempo que puede venir en formato AM/PM
      final timeStr = time.replaceAll(RegExp(r'[^\d:]'), '');
      final timeParts = timeStr.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      // Ajustar para formato AM/PM si es necesario
      if (time.toLowerCase().contains('pm') && hour != 12) {
        hour += 12;
      } else if (time.toLowerCase().contains('am') && hour == 12) {
        hour = 0;
      }

      return DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        hour,
        minute,
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<void> _createEvent() async {
    if (!_validateForm()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showErrorDialog('Token de autenticación no encontrado');
        return;
      }

      // Combinar fecha y hora
      final startDateTime = _combineDateTime(
        startDateController.text,
        startTimeController.text,
      );
      final endDateTime = _combineDateTime(
        startDateController.text,
        endTimeController.text,
      );

      final body = {
        "eventName": eventNameController.text,
        "eventDescription": descriptionController.text,
        "eventDetailsStartDateEvent": startDateTime.toIso8601String(),
        "eventDetailsEndDateEvent": endDateTime.toIso8601String(),
        "eventDetailsKindOfPublicity": kindOfPublicityController.text,
        "jobDetailsJobToDo": jobToDoController.text,
        "jobDetailsPayFare": double.tryParse(payFareController.text) ?? 0.0,
        "jobDetailsShowPayment": showPayment,
        "jobDetailsQuantityOfPeople":
            int.tryParse(quantityController.text) ?? 1,
        "address": addressController.text,
        "latitude": selectedLocation.latitude,
        "longitude": selectedLocation.longitude,
      };

      final response = await http.post(
        Uri.parse('https://influyo-testing.ryzeon.me/api/v1/entities/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Error al crear el evento: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error de conexión: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _validateForm() {
    if (eventNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        startDateController.text.isEmpty ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty ||
        kindOfPublicityController.text.isEmpty ||
        jobToDoController.text.isEmpty ||
        payFareController.text.isEmpty ||
        quantityController.text.isEmpty ||
        addressController.text.isEmpty) {
      _showErrorDialog('Por favor, completa todos los campos obligatorios');
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Éxito'),
          content: const Text('Evento creado exitosamente'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Volver a la página anterior
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildProfileSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => _showImagePickerDialog(false),
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFC4C4C4),
                borderRadius: BorderRadius.circular(5),
                image: _coverImage != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(_coverImage!),
                      )
                    : null,
              ),
              child: _coverImage == null
                  ? Center(
                      child: SvgPicture.asset(
                        'assets/icons/cameraoutlineicon.svg',
                        width: 30,
                        height: 30,
                        color: Colors.black,
                      ),
                    )
                  : null,
            ),
          ),
          Positioned(
            right: 15,
            bottom: 15,
            child: GestureDetector(
              onTap: () => _showImagePickerDialog(false),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFB0B0B0),
                  child: SvgPicture.asset(
                    'assets/icons/camerafillicon.svg',
                    width: 16,
                    height: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1,
      VoidCallback? onTap,
      bool readOnly = false,
      TextInputType keyboardType = TextInputType.text,
      List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget buildAddressFieldWithSuggestions() {
    return Column(
      children: [
        buildTextField(
          'Dirección',
          addressController,
          keyboardType: TextInputType.streetAddress,
        ),
        if (showAddressSuggestions && addressPredictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  addressPredictions.length > 5 ? 5 : addressPredictions.length,
              itemBuilder: (context, index) {
                final prediction = addressPredictions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on, color: Colors.grey),
                  title: Text(
                    prediction.description ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () => _selectAddressPrediction(prediction),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: selectedLocation,
          zoom: 14.0,
        ),
        onTap: (position) {
          _onMapTapped(position);
          // Ocultar sugerencias cuando se toca el mapa
          setState(() {
            showAddressSuggestions = false;
          });
        },
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
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
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Crear evento',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Ocultar sugerencias cuando se toca fuera del campo
          setState(() {
            showAddressSuggestions = false;
          });
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Información general",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              buildProfileSection(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    buildTextField('Nombre del evento', eventNameController),
                    buildTextField(
                      'Descripción del evento',
                      descriptionController,
                      maxLines: 3,
                    ),
                    const Text(
                      "Detalles del evento",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      'Fecha del evento',
                      startDateController,
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField(
                            'Hora inicio',
                            startTimeController,
                            readOnly: true,
                            onTap: () => _selectTime(startTimeController),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: buildTextField(
                            'Hora fin',
                            endTimeController,
                            readOnly: true,
                            onTap: () => _selectTime(endTimeController),
                          ),
                        ),
                      ],
                    ),
                    const SectionTitleWidget("Tipo de publicidad"),
                    const SizedBox(height: 16),
                    _buildPublicityTypeSection(),
                    const SizedBox(height: 10),
                    const SectionTitleWidget(
                        "Trabajo a realizar y Participación"),
                    buildTextField('Trabajo a realizar', jobToDoController),
                    buildTextField(
                      'Remuneración (S/.)',
                      payFareController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                    Row(
                      children: [
                        RemunerationSwitchWidget(
                          isPublic: showPayment,
                          onChanged: (value) {
                            setState(() {
                              showPayment = value;
                            });
                          },
                        ),
                      ],
                    ),
                    buildTextField(
                      'Cant. de participantes',
                      quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Ubicación del evento",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    buildAddressFieldWithSuggestions(),
                    const Text(
                      "Selecciona la ubicación en el mapa:",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    buildMapSection(),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16, top: 20),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _createEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Crear Evento',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPublicityTypeSection() {
    return Column(
      children: [
        _buildPublicityOption(
          value: 'presencial',
          title: 'Publicidad presencial',
          subtitle: 'Publicidad que requiere que el influencer se dirija al lugar indicado.',
        ),
        const SizedBox(height: 12),
        _buildPublicityOption(
          value: 'virtual',
          title: 'Publicidad virtual',
          subtitle: 'Publicidad que se puede realizar desde cualquier lugar (no requiere la presencia física del influencer).',
        ),
      ],
    );
  }

  Widget _buildPublicityOption({
    required String value,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = selectedPublicityType == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPublicityType = value;
          kindOfPublicityController.text = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFFF2F2F7),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Color(0xFFF2F2F7),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.shade800,
                  width: 2,
                ),
                //color: isSelected ? Colors.blue : Colors.white,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.circle,
                      size: 12,
                      color: Colors.black,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.black : Colors.grey.shade800,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
