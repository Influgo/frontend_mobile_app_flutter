import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_mobile_app_flutter/core/utils/media_validation_helper.dart';

class InfluencerProfilePage extends StatefulWidget {
  const InfluencerProfilePage({super.key});

  @override
  _InfluencerProfilePageState createState() => _InfluencerProfilePageState();
}

Widget ErrorTextWidget({required String error}) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Text(
      error,
      style: const TextStyle(color: Colors.red, fontSize: 12),
    ),
  );
}

class _InfluencerProfilePageState extends State<InfluencerProfilePage> {
  // --- Controladores de Texto ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  //final TextEditingController facebookController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController twitchController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // --- Nodos de Foco ---
  final FocusNode instagramFocusNode = FocusNode();
  //final FocusNode facebookFocusNode = FocusNode();
  final FocusNode tiktokFocusNode = FocusNode();
  final FocusNode youtubeFocusNode = FocusNode();
  final FocusNode twitchFocusNode = FocusNode();

  // --- Variables de Estado de la UI ---
  bool showInstagramField = false;
  //bool showFacebookField = false;
  bool showTiktokField = false;
  bool showYoutubeField = false;
  bool showTwitchField = false;
  bool showCollaborations = false;

  String? selectedCategory;
  List<String> categories = [
    "Lifestyle",
    "Moda",
    "Tecnología",
    "Salud y Fitness",
    "Comida",
    "Viajes",
    "Gaming",
    "Belleza",
    "Educación"
  ];

  String? selectedDepartment;
  List<String> departments = [
    "Lima",
    "Arequipa",
    "Cusco",
    "La Libertad",
    "Piura",
    "Lambayeque",
    "Junín",
    "Ica",
    "Ancash",
    "Huánuco"
  ];

  // --- Variables de Lógica y Datos ---
  bool isLoading = true;
  bool isSaving = false;
  String? token;
  int? influencerId;
  int? userId;

  // --- Variables para detectar cambios ---
  bool _isDirty = false;
  String? _initialName,
      _initialNickname,
      _initialSummary,
      _initialDescription,
      _initialInstagram,
      //_initialFacebook,
      _initialTiktok,
      _initialYoutube,
      _initialTwitch,
      _initialSelectedCategory,
      _initialSelectedDepartment;
  bool? _initialShowCollaborations;
  List<Map<String, dynamic>>? _initialExistingExtraFiles;

  // --- Variables de Imágenes ---
  File? _profileImage;
  File? _coverImage;
  String? profileImageUrl;
  String? bannerImageUrl;
  final ImagePicker _picker = ImagePicker();

  // Para archivos extra
  List<File> _localExtraImages = [];
  List<File> _localExtraVideos = [];
  List<Map<String, dynamic>> _existingExtraFiles = [];
  final int _maxExtraImages = 5;
  final int _maxExtraVideos = 3;
  final int _maxTotalExtraFiles = 8;

  @override
  void initState() {
    super.initState();
    _loadToken();

    // Añadir listeners para detectar cambios
    nameController.addListener(_checkForChanges);
    nicknameController.addListener(_checkForChanges);
    summaryController.addListener(_checkForChanges);
    descriptionController.addListener(_checkForChanges);
    instagramController.addListener(_checkForChanges);
    //facebookController.addListener(_checkForChanges);
    tiktokController.addListener(_checkForChanges);
    youtubeController.addListener(_checkForChanges);
    twitchController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    // Limpiar listeners
    nameController.removeListener(_checkForChanges);
    nicknameController.removeListener(_checkForChanges);
    summaryController.removeListener(_checkForChanges);
    descriptionController.removeListener(_checkForChanges);
    instagramController.removeListener(_checkForChanges);
    //facebookController.removeListener(_checkForChanges);
    tiktokController.removeListener(_checkForChanges);
    youtubeController.removeListener(_checkForChanges);
    twitchController.removeListener(_checkForChanges);

    // Limpiar controladores
    nameController.dispose();
    nicknameController.dispose();
    summaryController.dispose();
    descriptionController.dispose();
    instagramController.dispose();
    //facebookController.dispose();
    youtubeController.dispose();
    tiktokController.dispose();
    twitchController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void _setInitialValues() {
    _initialName = nameController.text;
    _initialNickname = nicknameController.text;
    _initialSummary = summaryController.text;
    _initialDescription = descriptionController.text;
    _initialInstagram = instagramController.text;
    //_initialFacebook = facebookController.text;
    _initialTiktok = tiktokController.text;
    _initialYoutube = youtubeController.text;
    _initialTwitch = twitchController.text;
    _initialSelectedCategory = selectedCategory;
    _initialSelectedDepartment = selectedDepartment;
    _initialShowCollaborations = showCollaborations;

    if (_existingExtraFiles.isNotEmpty) {
      _initialExistingExtraFiles = _existingExtraFiles
          .map<Map<String, dynamic>>((fileMap) =>
              Map<String, dynamic>.from(fileMap))
          .toList();
    } else {
      _initialExistingExtraFiles = [];
    }

    _localExtraImages.clear();
    _localExtraVideos.clear();

    setState(() {
      _isDirty = false;
    });
  }

  void _checkForChanges() {
    bool extraFilesChanged =
        _localExtraImages.isNotEmpty || _localExtraVideos.isNotEmpty;
    if (_initialExistingExtraFiles != null &&
        _existingExtraFiles.length != _initialExistingExtraFiles!.length) {
      extraFilesChanged = true;
    } else if (_initialExistingExtraFiles != null) {
      // Chequeo más profundo si las longitudes son iguales pero el contenido podría haber cambiado (ej. por ID)
      for (var i = 0; i < _existingExtraFiles.length; i++) {
        if (_existingExtraFiles[i]['id'] !=
            _initialExistingExtraFiles![i]['id']) {
          // Asumiendo que los archivos existentes tienen un 'id'
          extraFilesChanged = true;
          break;
        }
      }
    }

    bool changed = _initialName != nameController.text ||
        _initialNickname != nicknameController.text ||
        _initialSummary != summaryController.text ||
        _initialDescription != descriptionController.text ||
        _initialSelectedCategory != selectedCategory ||
        _initialSelectedDepartment != selectedDepartment ||
        _initialShowCollaborations != showCollaborations ||
        _profileImage != null ||
        _coverImage != null ||
        _initialInstagram != instagramController.text ||
        //_initialFacebook != facebookController.text ||
        _initialTiktok != tiktokController.text ||
        _initialYoutube != youtubeController.text ||
        _initialTwitch != twitchController.text ||
        extraFilesChanged;

    if (_isDirty != changed) {
      setState(() {
        _isDirty = changed;
      });
    }
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      String? userIdString = prefs.getString('userId');
      if (userIdString != null) {
        userId = int.tryParse(userIdString);
        print('✅ User ID cargado: $userId');
      }
      
      if (token != null) {
        await fetchInfluencerData();
      } else {
        setState(() {
          isLoading = false;
        });
        showSnackBar('No se encontró el token de autenticación');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('❌ Error cargando token: $e');
      showSnackBar('Error al cargar datos de autenticación');
    }
  }

  Future<void> fetchInfluencerData() async {
    setState(() {
      isLoading = true;
      _localExtraImages.clear();
      _localExtraVideos.clear();
      _existingExtraFiles.clear();
    });

    final String url =
        'https://influyo-testing.ryzeon.me/api/v1/entities/influencer/self';

    print('📥 Solicitando datos del influencer...');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final dynamic decodedJson = jsonDecode(response.body);

        if (decodedJson is! Map) {
          print(
              '❌ Error: La respuesta JSON no es un mapa. Respuesta: $decodedJson');
          showSnackBar('Error: Formato de respuesta inesperado del servidor.',
              isError: true);
          setState(() => isLoading = false);
          return;
        }

        // Convertir el mapa raíz explícitamente
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(decodedJson as Map);

        // final data = jsonDecode(response.body);
        print('📥 Datos obtenidos: $data');

        if (data['id'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('influencer_id', data['id']);
          influencerId = data['id'];
          print('✅ ID de influencer guardado: $influencerId');
        }

        setState(() {
          nameController.text = data['influencerInformationInfluencerName'] ?? '';
          nicknameController.text = data['alias'] ?? '';
          summaryController.text =
              data['influencerInformationInfluencerSummary'] ?? '';
          descriptionController.text =
              data['influencerInformationInfluencerDescription'] ?? '';
          if (summaryController.text == "N/A" &&
              descriptionController.text == "N/A") {
            summaryController.text = "";
            descriptionController.text = "";
          }

          String? apiCategory =
              data['influencerInformationInfluencerCategory'];
          if (apiCategory != null && categories.contains(apiCategory)) {
            selectedCategory = apiCategory;
          } else {
            selectedCategory = null;
            if (apiCategory != null) {
              print(
                  '⚠️ Categoría del API "$apiCategory" no encontrada en la lista local. Usando null para Dropdown.');
            }
          }
          
          // Manejar influencerAddress de forma segura
          String locationText = 'Lima'; // valor por defecto
          try {
            var addressData = data['influencerAddress'];
            print('🔍 Estructura de influencerAddress: $addressData');
            print('🔍 Tipo de influencerAddress: ${addressData.runtimeType}');
            
            if (addressData != null) {
              if (addressData is String) {
                // Si es directamente un string (como "N/A")
                if (addressData == "N/A" || addressData.isEmpty) {
                  locationText = 'Lima'; // mantener valor por defecto
                } else {
                  locationText = addressData;
                }
                print('✅ Address como string: "$addressData" → Usando: "$locationText"');
              } else if (addressData is Map) {
                // Si es un mapa, buscar 'department'
                locationText = addressData['department']?.toString() ?? 'Lima';
                print('✅ Department extraído del mapa: $locationText');
              } else if (addressData is List && addressData.isNotEmpty) {
                // Si es una lista, tomar el primer elemento
                var firstAddress = addressData[0];
                if (firstAddress is Map) {
                  locationText = firstAddress['department']?.toString() ?? 
                               firstAddress['address']?.toString() ?? 
                               firstAddress.toString();
                } else {
                  locationText = firstAddress.toString();
                }
                print('✅ Address extraído de la lista: $locationText');
              }
            }
          } catch (e) {
            print('⚠️ Error procesando influencerAddress: $e');
            locationText = 'Lima'; // mantener valor por defecto
          }
          
          locationController.text = locationText;
          
          // Asignar selectedDepartment basado en locationText
          if (departments.contains(locationText)) {
            selectedDepartment = locationText;
            print('✅ selectedDepartment asignado: $selectedDepartment');
          } else {
            selectedDepartment = null; // No está en la lista de departamentos
            print('⚠️ "$locationText" no está en la lista de departamentos. selectedDepartment = null');
          }
          
          profileImageUrl = (data['influencerLogo'] is Map
              ? (data['influencerLogo'] as Map)['url']?.toString()
              : null);
          bannerImageUrl = (data['influencerBanner'] is Map
              ? (data['influencerBanner'] as Map)['url']?.toString()
              : null);

          // Resetear controladores de redes sociales antes de poblar
          showInstagramField = false;
          instagramController.clear();
          showTiktokField = false;
          //showFacebookField = false;
          //facebookController.clear();
          tiktokController.clear();
          showYoutubeField = false;
          youtubeController.clear();
          showTwitchField = false;
          twitchController.clear();

          if (data['socialDtos'] != null && data['socialDtos'] is List) {
            for (var socialItem in (data['socialDtos'] as List)) {
              // Asegurar que cada item de la lista es un mapa y convertirlo
              if (socialItem is Map) {
                final Map<String, dynamic> social =
                    Map<String, dynamic>.from(socialItem);
                final name = social['name']?.toString().toLowerCase();
                final urlValue = social['socialUrl']?.toString() ?? '';
                if (urlValue.isNotEmpty) {
                  switch (name) {
                    case 'instagram':
                      showInstagramField = true;
                      instagramController.text = urlValue;
                      break;
                    // ... otros casos de redes sociales
                    /*case 'facebook':
                      showFacebookField = true;
                      facebookController.text = urlValue;
                      break;*/
                    case 'tiktok':
                      showTiktokField = true;
                      tiktokController.text = urlValue;
                      break;
                    case 'youtube':
                      showYoutubeField = true;
                      youtubeController.text = urlValue;
                      break;
                    case 'twitch':
                      showTwitchField = true;
                      twitchController.text = urlValue;
                      break;
                  }
                }
              } else {
                print(
                    "Advertencia: Elemento en socialDtos no es un mapa: $socialItem");
              }
            }
          }

          // ---------------------------------------------------------------------
          // CORRECCIÓN PARA s3Files
          // ---------------------------------------------------------------------
          if (data['s3Files'] != null && data['s3Files'] is List) {
            _existingExtraFiles.clear();
            for (var fileDataItem in (data['s3Files'] as List)) {
              if (fileDataItem is Map) {
                // Convertir cada mapa explícitamente
                final Map<String, dynamic> fileMap =
                    Map<String, dynamic>.from(fileDataItem);

                // Determinar el tipo (IMAGE o VIDEO) basado en filename o url si contentType no es útil
                String fileType = "UNKNOWN";
                String? contentType = fileMap['contentType']?.toString();
                String? filename =
                    fileMap['filename']?.toString().toLowerCase();
                String? fileUrl = fileMap['url']?.toString().toLowerCase();

                if (contentType != null) {
                  if (contentType.startsWith('image/')) {
                    fileType = 'IMAGE';
                  } else if (contentType.startsWith('video/')) {
                    fileType = 'VIDEO';
                  }
                  // Si es application/octet-stream, intentaremos inferir
                }

                // Si aún no se determina o es octet-stream, inferir de filename o url
                if (fileType == "UNKNOWN" ||
                    contentType == 'application/octet-stream') {
                  String? sourceForInference = filename ?? fileUrl;
                  if (sourceForInference != null) {
                    if (['.jpg', '.jpeg', '.png', '.gif', '.webp']
                        .any((ext) => sourceForInference.endsWith(ext))) {
                      fileType = 'IMAGE';
                    } else if (['.mp4', '.mov', '.avi', '.mkv', '.webm']
                        .any((ext) => sourceForInference.endsWith(ext))) {
                      fileType = 'VIDEO';
                    }
                  }
                }

                // Añadir un campo 'type' al mapa para usarlo en _buildExtraFileItemWidget
                fileMap['type'] =
                    fileType; // Este es el 'type' que _buildExtraFileItemWidget usará
                _existingExtraFiles.add(fileMap);
              } else {
                print(
                    "Advertencia: Elemento en s3Files no es un mapa: $fileDataItem");
              }
            }
            print("Archivos existentes procesados: $_existingExtraFiles");
          }
          // ---------------------------------------------------------------------
          // FIN CORRECCIÓN PARA s3Files
          // ---------------------------------------------------------------------
          
          _setInitialValues();
        });
      } else {
        print('❌ Error al obtener los datos. Código: ${response.statusCode}');

        print('❌ Body: ${response.body}');
        showSnackBar(
            'Error al obtener los datos del influencer: ${response.statusCode}');
      }
  } catch (e, s) {
      print('❌ Error en fetchInfluencerData: $e');
      print('❌ Stacktrace: $s');
      showSnackBar('Error de conexión al buscar datos: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1000,
      maxHeight: 1000,
    );
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _coverImage = File(pickedFile.path);
        }
        _checkForChanges();
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

  Future<bool> _updateInfluencerInfo() async {
    print('UserId: $userId');
    if (userId == null) {
      showSnackBar('ID de usuario no disponible.', isError: true);
      return false;
    }

    final url = Uri.parse(
        'https://influyo-testing.ryzeon.me/api/v1/entities/influencer/update');

    final Map<String, dynamic> body = {
      "id": userId,
      'influencerInformationInfluencerName': nameController.text,
      'alias': nicknameController.text,
      'influencerInformationInfluencerSummary': summaryController.text,
      'influencerInformationInfluencerDescription':
          descriptionController.text,
      if (selectedCategory != null)
        'influencerInformationInfluencerCategory': selectedCategory,
      'influencerAddress': selectedDepartment, // Enviar como string, no como objeto
    };

    print('📤 Actualizando información del influencer...');
    print('📤 URL: $url');
    print('📤 Token: ${token != null ? "Token presente (${token!.length} chars)" : "Token nulo"}');
    print('📤 Body: ${jsonEncode(body)}');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('📥 Info Update - Status: ${response.statusCode}');
      print('📥 Info Update - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Información del influencer actualizada correctamente.');
        return true;
      } else {
        print('❌ Error al actualizar la información: ${response.statusCode}');
        showSnackBar(
            'Error al actualizar la información del influencer: ${response.statusCode}',
            isError: true);
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión al actualizar la información: $e');
      showSnackBar('Error de conexión al actualizar la información: $e',
          isError: true);
      return false;
    }
  }

  Future<bool> _updateSocialMedia() async {
    if (influencerId == null) {
      showSnackBar('ID de influencer no disponible para redes sociales.',
          isError: true);
      return false;
    }
    
    List<Map<String, String>> socialDtos = [];

    if (showInstagramField && instagramController.text.isNotEmpty) {
      socialDtos.add({
        'name': 'instagram',
        'socialUrl': instagramController.text,
      });
    }
    /*if (showFacebookField && facebookController.text.isNotEmpty) {
      socialDtos.add({
        'name': 'facebook',
        'socialUrl': facebookController.text,
      });
    }*/
    if (showTiktokField && tiktokController.text.isNotEmpty) {
      socialDtos.add({
        'name': 'tiktok',
        'socialUrl': tiktokController.text,
      });
    }
    if (showYoutubeField && youtubeController.text.isNotEmpty) {
      socialDtos.add({
        'name': 'youtube',
        'socialUrl': youtubeController.text,
      });
    }
    if (showTwitchField && twitchController.text.isNotEmpty) {
      socialDtos.add({
        'name': 'twitch',
        'socialUrl': twitchController.text,
      });
    }

    // Verificar si realmente hay cambios en las redes sociales antes de enviar
    // Esto es importante para no enviar una petición si no es necesario,
    // o para enviar una lista vacía si el usuario borró todas las redes.
    bool socialMediaChanged = false;
    if (_initialInstagram != instagramController.text ||
        //_initialFacebook != facebookController.text ||
        _initialTiktok != tiktokController.text ||
        _initialYoutube != youtubeController.text ||
        _initialTwitch != twitchController.text) {
      socialMediaChanged = true;
    }
    // También considera si se activó/desactivó un campo de red social
    // (esto ya debería estar cubierto por _isDirty en _handleSaveChanges)

    // Si no hay DTOs para enviar Y los campos iniciales también estaban vacíos, no hay nada que hacer.
    if (socialDtos.isEmpty &&
        (_initialInstagram == null || _initialInstagram!.isEmpty) &&
        //(_initialFacebook == null || _initialFacebook!.isEmpty) &&
        (_initialTiktok == null || _initialTiktok!.isEmpty) &&
        (_initialYoutube == null || _initialYoutube!.isEmpty) &&
        (_initialTwitch == null || _initialTwitch!.isEmpty)) {
      print('ℹ️ No hay redes sociales para enviar y no había antes.');
      return true; // No hay cambios que enviar.
    }

    // --- CORRECCIÓN PRINCIPAL AQUÍ ---
    // Usar la URL base sin query parameters para socialDtos
    final url = Uri.parse(
        'https://influyo-testing.ryzeon.me/api/v1/entities/influencer/$influencerId/socials');
    // --- FIN DE LA CORRECCIÓN ---

    print('📤 Actualizando redes sociales...');
    print('📤 URL: $url');
    
    // Envolver el array en un objeto según lo que espera el backend
    final Map<String, dynamic> body = {
      'socialDtos': socialDtos,
    };
    
    print('📤 Body: ${jsonEncode(body)}');

    try {
      final response = await http.patch(
        url, // URL sin query params para socialDtos
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body), // Enviar el objeto que contiene el array
      );

      print('📥 Social Media Update - Status: ${response.statusCode}');
      print('📥 Social Media Update - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Redes sociales actualizadas.');
        // Actualizar los valores iniciales de las redes sociales después de un guardado exitoso
        _initialInstagram = instagramController.text;
        //_initialFacebook = facebookController.text;
        _initialTiktok = tiktokController.text;
        _initialYoutube = youtubeController.text;
        _initialTwitch = twitchController.text;
        return true;
      } else {
        showSnackBar(
            'Error al actualizar redes sociales: ${response.statusCode} - ${response.body}',
            isError: true);
        return false;
      }
    } catch (e) {
      print('❌ Error actualizando redes sociales: $e');
      showSnackBar('Error de conexión al actualizar redes sociales: $e',
          isError: true);
      return false;
    }
  }

  Future<bool> _uploadImageFile(File imageFile, String fileType) async {
    if (influencerId == null) {
      showSnackBar('ID de influencer no disponible para subir imagen.',
          isError: true);
      return false;
    }

    final url = Uri.parse(
        'https://influyo-testing.ryzeon.me/api/v1/entities/influencer/upload/$influencerId?fileType=$fileType');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
        'file', imageFile.path));

    print('📤 Subiendo imagen ($fileType)...');
    print('📤 URL: $url');

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Image Upload ($fileType) - Status: ${response.statusCode}');
      print('📥 Image Upload ($fileType) - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Imagen ($fileType) subida con éxito.');
        // Opcional: parsear la respuesta si devuelve la nueva URL de la imagen y actualizar logoImageUrl/bannerImageUrl
        final data = jsonDecode(response.body);
        if (fileType == "LOGO") setState(() => profileImageUrl = data['url']);
        if (fileType == "BANNER") setState(() => bannerImageUrl = data['url']);
        return true;
      } else {
        showSnackBar(
            'Error al subir imagen ($fileType): ${response.statusCode} - ${response.body}',
            isError: true);
        return false;
      }
    } catch (e) {
      print('❌ Error subiendo imagen ($fileType): $e');
      showSnackBar('Error de conexión al subir imagen ($fileType): $e',
          isError: true);
      return false;
    }
  }

  Future<void> _handleSaveChanges() async {
    if (!_isDirty) {
      showSnackBar("No hay cambios para guardar.");
      return;
    }
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    bool infoUpdated = false;
    bool socialsUpdated = false;
    bool logoUploaded = true; // Asumir éxito si no hay nueva imagen
    bool bannerUploaded = true; // Asumir éxito si no hay nueva imagen
    bool extraFilesUploaded = true;

    // 1. Actualizar información principal
    infoUpdated = await _updateInfluencerInfo();

    // 2. Actualizar redes sociales (solo si la info se actualizó Y las redes sociales cambiaron)
    bool socialMediaChanged = _initialInstagram != instagramController.text ||
        _initialTiktok != tiktokController.text ||
        _initialYoutube != youtubeController.text ||
        _initialTwitch != twitchController.text;
        
    if (infoUpdated && socialMediaChanged) {
      socialsUpdated = await _updateSocialMedia();
    } else {
      socialsUpdated = true; // No hay cambios en redes sociales, se considera exitoso
    }

    // 3. Subir imagen de perfil/logo (solo si lo anterior tuvo éxito y hay nueva imagen)
    if (infoUpdated && socialsUpdated && _profileImage != null) {
      logoUploaded = await _uploadImageFile(_profileImage!, "LOGO");
      if (logoUploaded) _profileImage = null; // Limpiar para no resubir
    }

    // 4. Subir imagen de portada/banner (solo si lo anterior tuvo éxito y hay nueva imagen)
    if (infoUpdated && socialsUpdated && logoUploaded && _coverImage != null) {
      bannerUploaded = await _uploadImageFile(_coverImage!, "BANNER");
      if (bannerUploaded) _coverImage = null; // Limpiar para no resubir
    }

    // 5. NUEVO: Subir archivos extra
    if (infoUpdated && socialsUpdated && logoUploaded && bannerUploaded) {
      // Subir imágenes extra locales
      for (File imageFile in _localExtraImages) {
        bool success = await _uploadImageFile(imageFile, "EXTRA");
        if (!success) {
          extraFilesUploaded = false;
          showSnackBar(
              "Error al subir una imagen extra: ${imageFile.path.split('/').last}",
              isError: true);
          // Podrías decidir romper el bucle aquí o continuar subiendo los demás
          // break;
        }
      }
      // Subir videos extra locales (si la subida de imágenes fue bien o decides continuar)
      if (extraFilesUploaded) {
        for (File videoFile in _localExtraVideos) {
          bool success = await _uploadImageFile(videoFile,
              "EXTRA"); // Asume que _uploadImageFile puede manejar videos
          if (!success) {
            extraFilesUploaded = false;
            showSnackBar(
                "Error al subir un video extra: ${videoFile.path.split('/').last}",
                isError: true);
            // break;
          }
        }
      }

      if (extraFilesUploaded) {
        _localExtraImages.clear();
        _localExtraVideos.clear();
      }
    }

    setState(() {
      isSaving = false;
    });

    if (infoUpdated &&
        socialsUpdated &&
        logoUploaded &&
        bannerUploaded &&
        extraFilesUploaded) {
      showSnackBar('¡Perfil actualizado con éxito!');
      await fetchInfluencerData(); // Recargar datos para reflejar todos los cambios
      // _setInitialValues(); // fetchInfluencerData ya llama a _setInitialValues
      setState(() {
        _isDirty = false;
      }); // Marcar como no sucio

      // Opcional: navegar hacia atrás
      // Future.delayed(const Duration(seconds: 1), () {
      //   if (mounted) Navigator.pop(context, true); // true para indicar que hubo cambios
      // });
    } else {
      showSnackBar(
          'Algunos cambios no se pudieron guardar. Revisa los mensajes de error.',
          isError: true);
    }
  }

  Widget buildProfileSection() {
    return Stack(
      alignment: Alignment.bottomLeft,
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _showImagePickerDialog(false),
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFC4C4C4),
              image: _coverImage != null
                  ? DecorationImage(
                      fit: BoxFit.cover, image: FileImage(_coverImage!))
                  : (bannerImageUrl != null && bannerImageUrl!.isNotEmpty
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(bannerImageUrl!))
                      : null),
            ),
            child: (_coverImage == null &&
                    (bannerImageUrl == null || bannerImageUrl!.isEmpty))
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
          bottom: -15,
          child: GestureDetector(
            onTap: () => _showImagePickerDialog(false),
            child: CircleAvatar(
              radius: 16,
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
        Positioned(
          left: 20,
          bottom: -40,
          child: GestureDetector(
            onTap: () => _showImagePickerDialog(true),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: const Color(0xFFC4C4C4),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : null) as ImageProvider?,
                    child: (_profileImage == null &&
                            (profileImageUrl == null || profileImageUrl!.isEmpty))
                        ? SvgPicture.asset(
                            'assets/icons/cameraoutlineicon.svg',
                            width: 30,
                            height: 30,
                            color: Colors.black,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showImagePickerDialog(true),
                    child: CircleAvatar(
                      radius: 16,
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
          ),
        ),
      ],
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, FocusNode? focusNode}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: StatefulBuilder(
        builder: (context, setState) {
          controller.addListener(() {
            setState(() {});
          });

          final isEmpty = controller.text.isEmpty;

          return TextField(
            controller: controller,
            maxLines: maxLines,
            focusNode: focusNode,
            style: TextStyle(
              color: isEmpty ? Colors.grey[600] : Colors.black,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 14,
                color: isEmpty ? Colors.grey : Colors.black,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            ),
          );
        },
      ),
    );
  }


  // Archivos extra con validación
  Future<void> _pickExtraFile(String type) async {
    if (type == 'IMAGE' &&
        _localExtraImages.length + _getExistingFilesCount('IMAGE') >=
            _maxExtraImages) {
      showSnackBar("Has alcanzado el límite de $_maxExtraImages imágenes.",
          isError: true);
      return;
    }
    if (type == 'VIDEO' &&
        _localExtraVideos.length + _getExistingFilesCount('VIDEO') >=
            _maxExtraVideos) {
      showSnackBar("Has alcanzado el límite de $_maxExtraVideos videos.",
          isError: true);
      return;
    }

    ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(type == 'IMAGE' ? 'Galería (Imágenes)' : 'Galería (Videos)'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(type == 'IMAGE' ? 'Cámara (Foto)' : 'Cámara (Video)'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    if (type == 'IMAGE') {
      await _pickAndValidateImages(source);
    } else if (type == 'VIDEO') {
      await _pickAndValidateVideo(source);
    }
  }

  Future<void> _pickAndValidateImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        // Para galería, permitir selección múltiple
        final List<XFile>? pickedFiles = await _picker.pickMultipleMedia(
          imageQuality: 70,
          maxWidth: 1200,
        );
        
        if (pickedFiles != null && pickedFiles.isNotEmpty) {
          // Filtrar solo imágenes
          final List<File> imageFiles = pickedFiles
              .where((file) => _isImageFile(file.path))
              .map((file) => File(file.path))
              .toList();
          
          if (imageFiles.isNotEmpty) {
            await _validateAndAddImages(imageFiles);
          } else {
            showSnackBar("No se seleccionaron imágenes válidas.", isError: true);
          }
        }
      } else {
        // Para cámara, solo una imagen
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 70,
          maxWidth: 1200,
        );
        
        if (pickedFile != null) {
          await _validateAndAddImages([File(pickedFile.path)]);
        }
      }
    } catch (e) {
      showSnackBar("Error al seleccionar imágenes: $e", isError: true);
    }
  }

  Future<void> _pickAndValidateVideo(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 2), // Permitimos 2 min para luego validar exactamente 1 min
      );
      
      if (pickedFile != null) {
        await _validateAndAddVideo(File(pickedFile.path));
      }
    } catch (e) {
      showSnackBar("Error al seleccionar video: $e", isError: true);
    }
  }

  Future<void> _validateAndAddImages(List<File> imageFiles) async {
    // Mostrar loading
    showSnackBar("Validando imágenes...");
    
    final validationResult = await MediaValidationHelper.validateMultipleFiles(
      imageFiles, 
      'IMAGE'
    );
    
    final List<File> validFiles = validationResult['validFiles'];
    final List<String> errorMessages = validationResult['errorMessages'];
    
    // Verificar límites después de la validación
    final int availableSlots = _maxExtraImages - (_localExtraImages.length + _getExistingFilesCount('IMAGE'));
    final List<File> filesToAdd = validFiles.take(availableSlots).toList();
    
    if (filesToAdd.isNotEmpty) {
      setState(() {
        _localExtraImages.addAll(filesToAdd);
        _checkForChanges();
      });
    }

    // Mostrar mensaje de resultado
    String message = MediaValidationHelper.getValidationSummaryMessage(validationResult);
    
    if (filesToAdd.length < validFiles.length) {
      message += " Algunas imágenes no se agregaron por límite de espacio.";
    }
    
    showSnackBar(message, isError: errorMessages.isNotEmpty);
    
    // Mostrar errores específicos si los hay
    if (errorMessages.isNotEmpty) {
      Future.delayed(const Duration(seconds: 2), () {
        showSnackBar(errorMessages.first, isError: true);
      });
    }
  }

  Future<void> _validateAndAddVideo(File videoFile) async {
    // Mostrar loading
    showSnackBar("Validando video...");
    
    final validationResult = await MediaValidationHelper.validateVideo(videoFile);
    
    if (validationResult.isValid) {
      setState(() {
        _localExtraVideos.add(videoFile);
        _checkForChanges();
      });
      
      String durationText = validationResult.videoDuration != null 
          ? MediaValidationHelper.formatDuration(validationResult.videoDuration!)
          : "";
      
      showSnackBar("Video agregado exitosamente${durationText.isNotEmpty ? ' ($durationText)' : ''}.");
    } else {
      showSnackBar(validationResult.errorMessage ?? "Error al validar el video.", isError: true);
    }
  }

  bool _isImageFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  void _removeLocalExtraFile(File file, String type) {
    setState(() {
      if (type == 'IMAGE') {
        _localExtraImages.remove(file);
      } else if (type == 'VIDEO') {
        _localExtraVideos.remove(file);
      }
      _checkForChanges();
    });
  }

  void _removeExistingExtraFile(Map<String, dynamic> fileData) {
    setState(() {
      _existingExtraFiles.removeWhere(
          (f) => f['id'] == fileData['id']); // Asumiendo que hay un 'id'
      _checkForChanges();
    });
    // NOTA: Esto solo lo quita de la UI. La eliminación real del servidor
    // requeriría una llamada API DELETE o que el endpoint de update maneje una lista
    // de los archivos a conservar. Por ahora, no se eliminará del servidor.
    showSnackBar(
        "El archivo '${fileData['url']?.split('/')?.last}' se quitará de la vista. Para eliminarlo permanentemente del servidor, se necesitaría una acción adicional (no implementada aquí).");
  }

  int _getExistingFilesCount(String typeToCount) {
    // ej: typeToCount = "IMAGE" o "VIDEO"
    return _existingExtraFiles.where((f) {
      // Usar el campo 'type' que agregamos en fetchInfluencerData
      String? actualFileType = f['type']?.toString().toUpperCase();
      return actualFileType == typeToCount;
    }).length;
  }

  int _getTotalFilesCount() {
    return _localExtraImages.length +
        _localExtraVideos.length +
        _existingExtraFiles.length;
  }

  Widget _buildExtraFileItemWidget(dynamic fileOrData, bool isLocal) {
    File? localFile;
    Map<String, dynamic>? remoteData;
    String determinedFileType = "UNKNOWN"; // Valor predeterminado

    if (isLocal) {
      if (fileOrData is File) {
        localFile = fileOrData;
        final path = localFile.path.toLowerCase();
        determinedFileType = (path.endsWith(".mp4") || path.endsWith(".mov"))
            ? 'VIDEO'
            : 'IMAGE';
      } else {
        print(
            "Error: _buildExtraFileItemWidget con isLocal=true pero fileOrData no es File.");
      }
    } else {
      // Es un archivo remoto
      if (fileOrData is Map<String, dynamic>) {
        remoteData = fileOrData;
        // Usar el campo 'type' que pre-procesamos en fetchInfluencerData
        determinedFileType = remoteData['type']?.toString() ?? "UNKNOWN";
      } else {
        print(
            "Error: _buildExtraFileItemWidget con isLocal=false pero fileOrData no es Map.");
      }
    }

    // Si después de todo, el tipo es UNKNOWN, o los datos base son nulos cuando no deberían
    if (determinedFileType == "UNKNOWN" ||
        (remoteData == null && !isLocal) ||
        (localFile == null && isLocal)) {
      print(
          "No se pudo determinar el tipo o datos inválidos para el archivo: ${isLocal ? localFile?.path : remoteData?['url']}");
      return Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Tooltip(
            message:
                "Error: Archivo no válido o tipo desconocido. ${isLocal ? 'Local' : remoteData?['url']}",
            child:
                const Icon(Icons.error_outline, color: Colors.red, size: 30)),
      );
    }

    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        children: [
          if (determinedFileType == 'IMAGE')
            isLocal && localFile != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.file(localFile,
                      fit: BoxFit.cover, width: 80, height: 80),
                )
                : (remoteData != null && remoteData['url'] != null
                    ? ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                          remoteData['url'].toString(),
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 30),
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                    )
                    : const Icon(Icons.image,
                        size:
                            30)) // Placeholder si la URL es null o remoteData es null
          else if (determinedFileType == 'VIDEO')
            Icon(Icons.videocam, size: 40, color: Colors.grey[700])
          else // Fallback si determinedFileType no es IMAGE ni VIDEO (aunque ya cubierto por el UNKNOWN arriba)
            Icon(Icons.insert_drive_file_outlined,
                size: 30, color: Colors.grey[700]),
          Positioned(
            top: -5,
            right: -5,
            child: IconButton(
              icon:
                  const Icon(Icons.remove_circle, color: Colors.red, size: 20),
              onPressed: () {
                if (isLocal && localFile != null) {
                  _removeLocalExtraFile(localFile, determinedFileType);
                } else if (!isLocal && remoteData != null) {
                  _removeExistingExtraFile(remoteData);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // MODIFICADO: Anteriormente buildImageUploadButton()
  Widget buildExtraFilesSection() {
    List<Widget> fileWidgets = [];

    // Archivos existentes del servidor
    for (var existingFile in _existingExtraFiles) {
      fileWidgets.add(_buildExtraFileItemWidget(existingFile, false));
    }
    // Archivos locales de imagen
    for (var localImage in _localExtraImages) {
      fileWidgets.add(_buildExtraFileItemWidget(localImage, true));
    }
    // Archivos locales de video
    for (var localVideo in _localExtraVideos) {
      fileWidgets.add(_buildExtraFileItemWidget(localVideo, true));
    }

    // Botón de agregar si no se ha alcanzado el límite total
    if (_getTotalFilesCount() < _maxTotalExtraFiles) {
      fileWidgets.add(
        GestureDetector(
          onTap: () {
            // Mostrar opciones: Imagen o Video
            showModalBottomSheet(
              context: context,
              builder: (BuildContext ctx) {
                return SafeArea(
                  child: Wrap(
                    children: <Widget>[
                      if (_localExtraImages.length +
                              _getExistingFilesCount('IMAGE') <
                          _maxExtraImages)
                        ListTile(
                          leading: const Icon(Icons.image),
                          title: const Text('Agregar Imagen'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _pickExtraFile('IMAGE');
                          },
                        ),
                      if (_localExtraVideos.length +
                              _getExistingFilesCount('VIDEO') <
                          _maxExtraVideos)
                        ListTile(
                          leading: const Icon(Icons.videocam),
                          title: const Text('Agregar Video'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _pickExtraFile('VIDEO');
                          },
                        ),
                      if ((_localExtraImages.length +
                                  _getExistingFilesCount('IMAGE') >=
                              _maxExtraImages) &&
                          (_localExtraVideos.length +
                                  _getExistingFilesCount('VIDEO') >=
                              _maxExtraVideos))
                        const ListTile(
                          title: Text('Has alcanzado el límite de archivos.'),
                        ),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.add, size: 30),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 4.0, // Espacio horizontal entre items
      runSpacing: 4.0, // Espacio vertical entre filas
      children: fileWidgets,
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProfileSection(),
                        const SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildTextField('Nombre del influencer',
                                  nameController),
                              buildTextField('Nickname del influencer',
                                  nicknameController),
                              const SizedBox(height: 10),
                              const Text("Detalle del influencer",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: DropdownButtonFormField<String>(
                                  value: selectedCategory,
                                  decoration: InputDecoration(
                                    labelText: "Categoría principal",
                                    labelStyle: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 12),
                                  ),
                                  items: categories.map((String category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedCategory = newValue;
                                      _checkForChanges();
                                    });
                                  },
                                  hint: const Text('Seleccione una categoría'),
                                  isExpanded: true,
                                ),
                              ),
                              const SizedBox(height: 10),
                              buildTextField('Resumen del influencer',
                                  summaryController),
                              buildTextField('Descripción del influencer',
                                  descriptionController,
                                  maxLines: 3),
                              const SizedBox(height: 20),
                              const Text("Redes sociales",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 10),
                              // Instagram
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Instagram',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey)),
                                  Radio<bool>(
                                    value:
                                        true, // Siempre true para que el grupo funcione
                                    groupValue:
                                        showInstagramField, // El valor del grupo es el booleano
                                    onChanged: (bool? value) {
                                      setState(() {
                                        showInstagramField =
                                            !showInstagramField;
                                        if (!showInstagramField) {
                                          instagramController
                                              .clear(); // Limpiar si se oculta
                                        }
                                        _checkForChanges();
                                      });
                                      if (showInstagramField) {
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          FocusScope.of(context)
                                              .requestFocus(instagramFocusNode);
                                        });
                                      }
                                    },
                                    activeColor: Colors.black,
                                  ),
                                ],
                              ),
                              if (showInstagramField) ...[
                                buildTextField(
                                    'Cuenta de Instagram', instagramController,
                                    focusNode: instagramFocusNode),
                                const SizedBox(height: 8),
                              ],
                              const Divider(color: Colors.grey, thickness: 0.3),
                              /*
                              // Facebook
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Facebook',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey)),
                                  Radio<bool>(
                                    value:
                                        true, // Siempre true para que el grupo funcione
                                    groupValue:
                                        showFacebookField, // El valor del grupo es el booleano
                                    onChanged: (bool? value) {
                                      setState(() {
                                        showFacebookField =
                                            !showFacebookField;
                                        if (!showFacebookField) {
                                          instagramController
                                              .clear(); // Limpiar si se oculta
                                        }
                                        _checkForChanges();
                                      });
                                      if (showFacebookField) {
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          FocusScope.of(context)
                                              .requestFocus(facebookFocusNode);
                                        });
                                      }
                                    },
                                    activeColor: Colors.black,
                                  ),
                                ],
                              ),
                              if (showFacebookField) ...[
                                buildTextField(
                                    'Cuenta de Facebook', facebookController,
                                    focusNode: facebookFocusNode),
                                const SizedBox(height: 8),
                              ],
                              const Divider(color: Colors.grey, thickness: 0.3),
                              */
                              // TikTok
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tiktok',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey)),
                                  Radio<bool>(
                                    value: true,
                                    groupValue: showTiktokField,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        showTiktokField = !showTiktokField;
                                        if (!showTiktokField) {
                                          tiktokController.clear();
                                        }
                                        _checkForChanges();
                                      });
                                      if (showTiktokField) {
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          FocusScope.of(context)
                                              .requestFocus(tiktokFocusNode);
                                        });
                                      }
                                    },
                                    activeColor: Colors.black,
                                  ),
                                ],
                              ),
                              if (showTiktokField) ...[
                                buildTextField(
                                    'Usuario de Tiktok', tiktokController,
                                    focusNode: tiktokFocusNode),
                                const SizedBox(height: 8),
                              ],
                              const Divider(color: Colors.grey, thickness: 0.3),
                              // Youtube
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Youtube',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey)),
                                  Radio<bool>(
                                    value: true,
                                    groupValue: showYoutubeField,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        showYoutubeField = !showYoutubeField;
                                        if (!showYoutubeField) {
                                          youtubeController.clear();
                                        }
                                        _checkForChanges();
                                      });
                                      if (showYoutubeField) {
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          FocusScope.of(context)
                                              .requestFocus(youtubeFocusNode);
                                        });
                                      }
                                    },
                                    activeColor: Colors.black,
                                  ),
                                ],
                              ),
                              if (showYoutubeField) ...[
                                buildTextField(
                                    'Canal de Youtube', youtubeController,
                                    focusNode: youtubeFocusNode),
                                const SizedBox(height: 8),
                              ],
                              const Divider(color: Colors.grey, thickness: 0.3),
                              // Twitch
                              
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Twitch',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey)),
                                  Radio<bool>(
                                    value: true,
                                    groupValue: showTwitchField,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        showTwitchField = !showTwitchField;
                                        if (!showTwitchField) {
                                          twitchController.clear();
                                        }
                                        _checkForChanges();
                                      });
                                      if (showTwitchField) {
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          FocusScope.of(context)
                                              .requestFocus(twitchFocusNode);
                                        });
                                      }
                                    },
                                    activeColor: Colors.black,
                                  ),
                                ],
                              ),
                              if (showTwitchField) ...[
                                buildTextField(
                                    'Canal de Twitch', twitchController,
                                    focusNode: twitchFocusNode),
                                const SizedBox(height: 8),
                              ],
                              const SizedBox(height: 20),
                              // buildTextField("Ubicación", locationController), // Comentado: usamos dropdown en su lugar
                              SizedBox(
                                width: double.infinity,
                                child: DropdownButtonFormField<String>(
                                  value: selectedDepartment,
                                  decoration: InputDecoration(
                                    labelText: "Ubicación",
                                    labelStyle: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 12),
                                  ),
                                  items: departments.map((String location) {
                                    return DropdownMenuItem<String>(
                                      value: location,
                                      child: Text(location),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedDepartment = newValue;
                                      _checkForChanges();
                                    });
                                  },
                                  hint: const Text('Departamento donde resides'),
                                  isExpanded: true,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                  "Selecciona los videos y fotos del influencer",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              const Text(
                                "Ahora puedes subir hasta 3 videos de 1 minuto máximo. ¡Aprovecha esta nueva opción para mostrar mejor tu perfil de influencer!",
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              // buildImageUploadButton(), // UI para "EXTRA" files
                              buildExtraFilesSection(),
                               // UI para "EXTRA" files

                              const SizedBox(height: 30),
                              const Text("Colaboraciones",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              const Text(
                                "¿Deseas mostrar tus colaboraciones en tu perfil? (Puedes cambiar esta opción en cualquier momento)",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              
                              Row(
                                children: [
                                  Checkbox(
                                    value: showCollaborations,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        showCollaborations = value ?? false;
                                        _checkForChanges();
                                      });
                                    },
                                    activeColor: Colors.black,
                                  ),
                                  const Text(
                                    "Sí, quiero mostrar mis colaboraciones",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
  
                               const SizedBox(height: 30),
                               SizedBox(
                                 width: double.infinity,
                                 child: ElevatedButton(
                                   onPressed: (_isDirty && !isSaving)
                                      ? _handleSaveChanges
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (_isDirty && !isSaving)
                                        ? Colors.black
                                        : Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    // disabledBackgroundColor: Colors.grey, // styleFrom ya lo maneja
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text("Guardar cambios",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                        child: Icon(Icons.arrow_back_ios,
                            color: Colors.black, size: 20),
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