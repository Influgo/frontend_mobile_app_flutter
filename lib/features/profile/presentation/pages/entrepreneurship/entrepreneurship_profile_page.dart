import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EntrepreneurshipProfilePage extends StatefulWidget {
  const EntrepreneurshipProfilePage({super.key});

  @override
  _EntrepreneurshipProfilePageState createState() =>
      _EntrepreneurshipProfilePageState();
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

class _EntrepreneurshipProfilePageState
    extends State<EntrepreneurshipProfilePage> {
  // --- Controladores de Texto ---
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController representativeController =
      TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController twitchController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController focusController = TextEditingController();
  final TextEditingController rucController = TextEditingController();

  // --- Nodos de Foco ---
  final FocusNode instagramFocusNode = FocusNode();
  final FocusNode tiktokFocusNode = FocusNode();
  final FocusNode youtubeFocusNode = FocusNode();
  final FocusNode twitchFocusNode = FocusNode();

  // --- Variables de Estado de la UI ---
  bool isPublic = true;
  bool showInstagramField = false;
  bool showTiktokField = false;
  bool showYoutubeField = false;
  bool showTwitchField = false;
  List<String> focusTags = [];
  List<String> addressList = [];

  String? selectedCategory;
  List<String> categories = [
    "Comida",
    "Moda",
    "Tecnología",
    "Salud",
    "Educación"
  ];
  String selectedModality = "N/A";

  // --- Variables de Lógica y Datos ---
  bool isLoading = true;
  bool isSaving = false;
  String? token;
  int? entrepreneurId;

  // --- Variables para detectar cambios ---
  bool _isDirty = false; // Para saber si hay cambios pendientes
  String? _initialBusinessName,
      _initialNickname,
      _initialRuc,
      _initialSummary,
      _initialDescription,
      _initialInstagram,
      _initialTiktok,
      _initialYoutube,
      _initialTwitch,
      _initialSelectedCategory,
      _initialSelectedModality;
  bool? _initialIsPublic;
  List<String>? _initialFocusTags, _initialAddressList;
  List<Map<String, dynamic>>? _initialExistingExtraFiles;

  // --- Variables de Imágenes ---
  File? _profileImage;
  File? _coverImage;
  String? logoImageUrl;
  String? bannerImageUrl;
  final ImagePicker _picker = ImagePicker();

  // NUEVO: Para archivos extra
  List<File> _localExtraImages = [];
  List<File> _localExtraVideos = [];
  List<Map<String, dynamic>> _existingExtraFiles =
      []; // e.g. [{'url': '...', 'type': 'IMAGE', 'id': '...'}, ...]
  // List<String>? _existingExtraFiles = [];
  final int _maxExtraImages = 5;
  final int _maxExtraVideos = 3;
  final int _maxTotalExtraFiles = 8;

  @override
  void initState() {
    super.initState();
    isPublic = true; // Valor inicial
    _loadToken();

    // Añadir listeners para detectar cambios
    businessNameController.addListener(_checkForChanges);
    nicknameController.addListener(_checkForChanges);
    rucController.addListener(_checkForChanges);
    summaryController.addListener(_checkForChanges);
    descriptionController.addListener(_checkForChanges);
    instagramController.addListener(_checkForChanges);
    tiktokController.addListener(_checkForChanges);
    youtubeController.addListener(_checkForChanges);
    twitchController.addListener(_checkForChanges);
    // representativeController y addressController se manejan al agregar/borrar
    // focusController se maneja al agregar/borrar
  }

  @override
  void dispose() {
    // Limpiar listeners
    businessNameController.removeListener(_checkForChanges);
    nicknameController.removeListener(_checkForChanges);
    rucController.removeListener(_checkForChanges);
    summaryController.removeListener(_checkForChanges);
    descriptionController.removeListener(_checkForChanges);
    instagramController.removeListener(_checkForChanges);
    tiktokController.removeListener(_checkForChanges);
    youtubeController.removeListener(_checkForChanges);
    twitchController.removeListener(_checkForChanges);

    // Limpiar controladores
    businessNameController.dispose();
    nicknameController.dispose();
    representativeController.dispose();
    summaryController.dispose();
    descriptionController.dispose();
    instagramController.dispose();
    youtubeController.dispose();
    tiktokController.dispose();
    twitchController.dispose();
    addressController.dispose();
    focusController.dispose();
    rucController.dispose();
    super.dispose();
  }

  void _setInitialValues() {
    _initialBusinessName = businessNameController.text;
    _initialNickname = nicknameController.text;
    _initialRuc = rucController.text;
    _initialSummary = summaryController.text;
    _initialDescription = descriptionController.text;
    _initialInstagram = instagramController.text;
    _initialTiktok = tiktokController.text;
    _initialYoutube = youtubeController.text;
    _initialTwitch = twitchController.text;
    _initialSelectedCategory = selectedCategory;
    _initialSelectedModality = selectedModality;
    _initialIsPublic = isPublic;
    _initialFocusTags = List.from(focusTags);
    _initialAddressList = List.from(addressList);
    // Las imágenes se comprueban por nulidad de _profileImage y _coverImage

    // _initialExistingExtraFiles = List<Map<String, dynamic>>.from(
    //     _existingExtraFiles.map((e) => Map.from(e)));

    if (_existingExtraFiles.isNotEmpty) {
      _initialExistingExtraFiles = _existingExtraFiles
          .map<Map<String, dynamic>>((fileMap) =>
              Map<String, dynamic>.from(fileMap)) // Conversión explícita
          .toList();
    } else {
      _initialExistingExtraFiles = []; // Si está vacía, inicializar como vacía
    }

    _localExtraImages.clear(); // Los archivos locales se resetean siempre
    _localExtraVideos.clear();

    setState(() {
      _isDirty = false; // Resetear dirty flag después de cargar/guardar
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

    bool changed = _initialBusinessName != businessNameController.text ||
        _initialNickname != nicknameController.text ||
        _initialRuc != rucController.text ||
        _initialSummary != summaryController.text ||
        _initialDescription != descriptionController.text ||
        _initialSelectedCategory != selectedCategory ||
        _initialSelectedModality != selectedModality ||
        _initialIsPublic != isPublic ||
        _profileImage != null || // Nueva imagen de perfil
        _coverImage != null || // Nueva imagen de portada
        _initialInstagram != instagramController.text ||
        _initialTiktok != tiktokController.text ||
        _initialYoutube != youtubeController.text ||
        _initialTwitch != twitchController.text ||
        !_listEquals(_initialFocusTags, focusTags) ||
        !_listEquals(_initialAddressList, addressList) ||
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
      if (token != null) {
        await fetchEntrepreneurData();
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

  Future<void> fetchEntrepreneurData() async {
    setState(() {
      isLoading = true;

      _localExtraImages.clear();
      _localExtraVideos.clear();
      _existingExtraFiles.clear();
    }); // Asegurar que isLoading esté true
    final String url =
        'https://influyo-testing.ryzeon.me/api/v1/entities/entrepreneur/self';

    print('📥 Solicitando datos del emprendimiento...');
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

        // Asegurarse de que el JSON decodificado sea un Mapa y convertirlo explícitamente
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
          await prefs.setInt('entrepreneurship_id', data['id']);
          entrepreneurId = data['id'];
          print('✅ ID de emprendimiento guardado: $entrepreneurId');
        }

        setState(() {
          businessNameController.text =
              data['entrepreneurshipInformationEntrepreneurshipName'] ?? '';
          nicknameController.text =
              data['entrepreneurshipInformationEntrepreneursNickname'] ?? '';
          rucController.text =
              data['entrepreneurshipInformationEntrepreneurshipRUC'] ?? '';
          summaryController.text =
              data['entrepreneurshipInformationSummary'] ?? '';
          descriptionController.text =
              data['entrepreneurshipInformationDescription'] ?? '';
          if (summaryController.text == "N/A" &&
              descriptionController.text == "N/A") {
            summaryController.text = "";
            descriptionController.text = "";
          }
          // isPublic = data['showOwnerName'] ?? true;
          isPublic = true;
          String? apiCategory = data['entrepreneurshipInformationCategory'];
          if (apiCategory != null && categories.contains(apiCategory)) {
            selectedCategory = apiCategory;
          } else {
            selectedCategory = null;
            if (apiCategory != null) {
              print(
                  '⚠️ Categoría del API "$apiCategory" no encontrada en la lista local. Usando null para Dropdown.');
            }
          }
          selectedModality = data['entrepreneurAddressAddressType'] ?? 'N/A';
          focusTags = data['entrepreneurFocus'] != null
              ? List<String>.from(data['entrepreneurFocus'])
              : [];
          addressList = data['entrepreneurAddresses'] != null
              ? List<String>.from(data['entrepreneurAddresses'])
              : [];

          if (data['entrepreneurFocus'] != null &&
              addressList.isNotEmpty &&
              addressList[0] == "N/A") {
            _removeAddress("N/A");
          }
          // logoImageUrl = data['entrepreneurLogo']?['url'];
          // bannerImageUrl = data['entrepreneurBanner']?['url'];
          logoImageUrl = (data['entrepreneurLogo'] is Map
              ? (data['entrepreneurLogo'] as Map)['url']?.toString()
              : null);
          bannerImageUrl = (data['entrepreneurBanner'] is Map
              ? (data['entrepreneurBanner'] as Map)['url']?.toString()
              : null);

          // Resetear controladores de redes sociales antes de poblar
          showInstagramField = false;
          instagramController.clear();
          showTiktokField = false;
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

          // if (data['socialDtos'] != null && data['socialDtos'] is List) {
          //   for (var social in data['socialDtos']) {
          //     final name = social['name']?.toString().toLowerCase();
          //     final urlValue = social['socialUrl'] ?? '';
          //     if (urlValue.isNotEmpty) {
          //       // Solo mostrar si hay URL
          //       switch (name) {
          //         case 'instagram':
          //           showInstagramField = true;
          //           instagramController.text = urlValue;
          //           break;
          //         case 'tiktok':
          //           showTiktokField = true;
          //           tiktokController.text = urlValue;
          //           break;
          //         case 'youtube':
          //           showYoutubeField = true;
          //           youtubeController.text = urlValue;
          //           break;
          //         case 'twitch':
          //           showTwitchField = true;
          //           twitchController.text = urlValue;
          //           break;
          //       }
          //     }
          //   }
          // }

          // if (data['s3Files'] != null && data['s3Files'] is List) {
          //   _existingExtraFiles = List<Map<String, dynamic>>.from(data['s3Files']);
          // }

          // if (data['s3Files'] != null && data['s3Files'] is List) {
          //   _existingExtraFiles
          //       .clear(); // Buena práctica para evitar duplicados si se llama varias veces
          //   for (var fileData in (data['s3Files'] as List)) {
          //     if (fileData is Map) {
          //       // Asegúrate de que el elemento sea un mapa
          //       _existingExtraFiles.add(Map<String, dynamic>.from(fileData));
          //     } else {
          //       // Opcional: Manejar el caso donde un elemento no es un mapa
          //       print(
          //           "Advertencia: Elemento en s3Files no es un mapa: $fileData");
          //     }
          //   }
          // }

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

          _setInitialValues(); // Guardar valores iniciales después de cargar
        });
      } else {
        print('❌ Error al obtener los datos. Código: ${response.statusCode}');

        print('❌ Body: ${response.body}');
        showSnackBar(
            'Error al obtener los datos del emprendimiento: ${response.statusCode}');
      }
    } catch (e, s) {
      print('❌ Error en fetchEntrepreneurData: $e');
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
      imageQuality: 80, // Opcional: reducir calidad para menor tamaño
      maxWidth: 1000, // Opcional: limitar dimensiones
      maxHeight: 1000,
    );
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _coverImage = File(pickedFile.path);
        }
        _checkForChanges(); // Hay un cambio
      });
    }
  }

  void _addFocusTag() {
    String text = focusController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        if (!focusTags.contains(text)) {
          // Evitar duplicados
          focusTags.add(text);
          focusController.clear();
          _checkForChanges();
        } else {
          showSnackBar("Este enfoque ya ha sido agregado.", isError: true);
        }
      });
    }
  }

  void _removeFocusTag(String tag) {
    setState(() {
      focusTags.remove(tag);
      _checkForChanges();
    });
  }

  void _addAddress() {
    String address = addressController.text.trim();
    if (address.isNotEmpty) {
      setState(() {
        if (!addressList.contains(address)) {
          // Evitar duplicados
          addressList.add(address);
          addressController.clear();
          _checkForChanges();
        } else {
          showSnackBar("Esta dirección ya ha sido agregada.", isError: true);
        }
      });
    }
  }

  void _removeAddress(String address) {
    setState(() {
      addressList.remove(address);
      _checkForChanges();
    });
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

  Future<bool> _updateEntrepreneurInfo() async {
    print('EntrepreneurId: $entrepreneurId');
    if (entrepreneurId == null) {
      showSnackBar('ID de emprendimiento no disponible.', isError: true);
      return false;
    }

    final url = Uri.parse(
        'https://influyo-testing.ryzeon.me/api/v1/entities/entrepreneur/update');
    final Map<String, dynamic> body = {
      'id': entrepreneurId,
      'entrepreneurshipInformationEntrepreneurshipName':
          businessNameController.text,
      'entrepreneurshipInformationEntrepreneursNickname':
          nicknameController.text,
      'entrepreneurshipInformationEntrepreneurshipRUC': rucController.text,
      // Solo enviar la categoría si ha sido seleccionada
      if (selectedCategory != null)
        'entrepreneurshipInformationCategory': selectedCategory,
      'entrepreneurshipInformationSummary': summaryController.text,
      'entrepreneurshipInformationDescription': descriptionController.text,
      'showOwnerName': true,
      'entrepreneurAddressAddressType': selectedModality,
      'entrepreneurFocus': focusTags,
      'entrepreneurAddresses': addressList,
    };

    print('📤 Actualizando información del emprendimiento...');
    print('📤 URL: $url');
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
        print('✅ Información del emprendimiento actualizada.');
        return true;
      } else {
        showSnackBar(
            'Error al actualizar información: ${response.statusCode} - ${response.body}',
            isError: true);
        return false;
      }
    } catch (e) {
      print('❌ Error actualizando información: $e');
      showSnackBar('Error de conexión al actualizar información: $e',
          isError: true);
      return false;
    }
  }

  Future<bool> _updateSocialMedia() async {
    if (entrepreneurId == null) {
      showSnackBar('ID de emprendimiento no disponible para redes sociales.',
          isError: true);
      return false;
    }

    List<Map<String, String>> socialDtos = [];
    if (showInstagramField && instagramController.text.isNotEmpty) {
      socialDtos
          .add({'name': 'Instagram', 'socialUrl': instagramController.text});
    }
    if (showTiktokField && tiktokController.text.isNotEmpty) {
      socialDtos.add({'name': 'Tiktok', 'socialUrl': tiktokController.text});
    }
    if (showYoutubeField && youtubeController.text.isNotEmpty) {
      socialDtos.add({'name': 'Youtube', 'socialUrl': youtubeController.text});
    }
    if (showTwitchField && twitchController.text.isNotEmpty) {
      socialDtos.add({'name': 'Twitch', 'socialUrl': twitchController.text});
    }

    // Verificar si realmente hay cambios en las redes sociales antes de enviar
    // Esto es importante para no enviar una petición si no es necesario,
    // o para enviar una lista vacía si el usuario borró todas las redes.
    bool socialMediaChanged = false;
    if (_initialInstagram != instagramController.text ||
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
        (_initialTiktok == null || _initialTiktok!.isEmpty) &&
        (_initialYoutube == null || _initialYoutube!.isEmpty) &&
        (_initialTwitch == null || _initialTwitch!.isEmpty)) {
      print('ℹ️ No hay redes sociales para enviar y no había antes.');
      return true; // No hay cambios que enviar.
    }

    // --- CORRECCIÓN PRINCIPAL AQUÍ ---
    // Usar la URL base sin query parameters para socialDtos
    final url = Uri.parse(
        'https://influyo-testing.ryzeon.me/api/v1/entities/entrepreneur/$entrepreneurId/socials');
    // --- FIN DE LA CORRECCIÓN ---

    print('📤 Actualizando redes sociales...');
    print('📤 URL: $url');
    // El body será el array de socialDtos directamente.
    print('📤 Body: ${jsonEncode(socialDtos)}');

    try {
      final response = await http.patch(
        url, // URL sin query params para socialDtos
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body:
            jsonEncode(socialDtos), // Enviar el array directamente como cuerpo
      );

      print('📥 Social Media Update - Status: ${response.statusCode}');
      print('📥 Social Media Update - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Redes sociales actualizadas.');
        // Actualizar los valores iniciales de las redes sociales después de un guardado exitoso
        _initialInstagram = instagramController.text;
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
    if (entrepreneurId == null) {
      showSnackBar('ID de emprendimiento no disponible para subir imagen.',
          isError: true);
      return false;
    }

    final url = Uri.parse(
        'https://influyo-testing.ryzeon.me/api/v1/entities/entrepreneur/upload/$entrepreneurId?fileType=$fileType');
    // final url = Uri.parse(
    //     'https://influyo-testing.ryzeon.me/api/v1/entities/entrepreneur/upload/27?fileType=$fileType');
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
        'file', imageFile.path)); // 'file' es el nombre común del campo

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
        if (fileType == "LOGO") setState(() => logoImageUrl = data['url']);
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
    infoUpdated = await _updateEntrepreneurInfo();

    // 2. Actualizar redes sociales (solo si la info se actualizó)
    if (infoUpdated) {
      socialsUpdated = await _updateSocialMedia();
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
      await fetchEntrepreneurData(); // Recargar datos para reflejar todos los cambios
      // _setInitialValues(); // fetchEntrepreneurData ya llama a _setInitialValues
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
          onTap: () => _showImagePickerDialog(false), // Para banner/cover
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
            onTap: () => _showImagePickerDialog(false), // Para banner/cover
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
            onTap: () => _showImagePickerDialog(true), // Para perfil/logo
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
                        : (logoImageUrl != null && logoImageUrl!.isNotEmpty
                            ? NetworkImage(logoImageUrl!)
                            : null) as ImageProvider?,
                    child: (_profileImage == null &&
                            (logoImageUrl == null || logoImageUrl!.isEmpty))
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
                    onTap: () =>
                        _showImagePickerDialog(true), // Para perfil/logo
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

  // Widget buildTextField(String label, TextEditingController controller,
  //     {int maxLines = 1, FocusNode? focusNode}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 12),
  //     child: TextField(
  //       controller: controller,
  //       maxLines: maxLines,
  //       focusNode: focusNode,
  //       decoration: InputDecoration(
  //         labelText: label,
  //         labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         contentPadding:
  //             const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  //       ),
  //       // onChanged: (value) => _checkForChanges(), // Los listeners ya hacen esto
  //     ),
  //   );
  // }

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

  Widget buildFocusTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: focusTags
          .map((tag) => Chip(
                label: Text(tag),
                onDeleted: () => _removeFocusTag(tag),
              ))
          .toList(),
    );
  }

  Widget buildAddressList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (addressList.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            "Direcciones agregadas:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 5),
          ...addressList.map((address) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(address),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () => _removeAddress(address),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // NUEVO: Lógica para seleccionar archivos extra
  Future<void> _pickExtraFile(String type) async {
    // type: 'IMAGE' o 'VIDEO'
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
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
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
      final XFile? pickedFile = await _picker.pickImage(
          source: source, imageQuality: 70, maxWidth: 1200);
      if (pickedFile != null) {
        setState(() {
          _localExtraImages.add(File(pickedFile.path));
          _checkForChanges();
        });
      }
    } else if (type == 'VIDEO') {
      final XFile? pickedFile = await _picker.pickVideo(
          source: source, maxDuration: const Duration(minutes: 1));
      if (pickedFile != null) {
        // Validar tamaño o duración si es necesario (ImagePicker.maxDuration es una sugerencia)
        // File video = File(pickedFile.path);
        // int fileSizeInBytes = video.lengthSync();
        // double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        // if (fileSizeInMB > TU_LIMITE_DE_MB) { showSnackBar("Video demasiado grande"); return; }
        setState(() {
          _localExtraVideos.add(File(pickedFile.path));
          _checkForChanges();
        });
      }
    }
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

  // int _getExistingFilesCount(String type) {
  //   return _existingExtraFiles.where((f) => f['contentType'] == type).length;
  // }

  int _getExistingFilesCount(String typeToCount) {
    // ej: typeToCount = "IMAGE" o "VIDEO"
    return _existingExtraFiles.where((f) {
      // Usar el campo 'type' que agregamos en fetchEntrepreneurData
      String? actualFileType = f['type']?.toString().toUpperCase();
      return actualFileType == typeToCount;
    }).length;
  }

  int _getTotalFilesCount() {
    return _localExtraImages.length +
        _localExtraVideos.length +
        _existingExtraFiles.length;
  }

  // NUEVO: Widget para un item de archivo extra (imagen o video)

// Dentro de _EntrepreneurshipProfilePageState


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
        // Usar el campo 'type' que pre-procesamos en fetchEntrepreneurData
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

  // Widget _buildExtraFileItemWidget(dynamic fileOrData, bool isLocal) {
  //   File? localFile = isLocal ? (fileOrData as File) : null;
  //   Map<String, dynamic>? remoteData =
  //       isLocal ? null : (fileOrData as Map<String, dynamic>);
  //   String fileType = isLocal
  //       ? (localFile!.path.toLowerCase().endsWith(".mp4") ||
  //               localFile.path.toLowerCase().endsWith(".mov")
  //           ? 'VIDEO'
  //           : 'IMAGE') // Inferencia simple
  //       : remoteData!['contentType']; // 'IMAGE' o 'VIDEO' desde la API
  //
  //   return Container(
  //     width: 80,
  //     height: 80,
  //     margin: const EdgeInsets.all(4.0),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         if (fileType == 'IMAGE')
  //           isLocal
  //               ? Image.file(localFile!,
  //                   fit: BoxFit.cover, width: 80, height: 80)
  //               : (remoteData!['url'] != null
  //                   ? Image.network(remoteData['url'],
  //                       fit: BoxFit.cover,
  //                       width: 80,
  //                       height: 80,
  //                       errorBuilder: (context, error, stackTrace) =>
  //                           Icon(Icons.broken_image, size: 30))
  //                   : Icon(Icons.image, size: 30))
  //         else // VIDEO
  //           Icon(Icons.videocam, size: 40, color: Colors.grey[700]),
  //         Positioned(
  //           top: -5,
  //           right: -5,
  //           child: IconButton(
  //             icon: Icon(Icons.remove_circle, color: Colors.red, size: 20),
  //             onPressed: () {
  //               if (isLocal) {
  //                 _removeLocalExtraFile(localFile!, fileType);
  //               } else {
  //                 _removeExistingExtraFile(remoteData!);
  //               }
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  // Widget buildImageUploadButton() {
  //   return GestureDetector(
  //     onTap: () {
  //       showSnackBar(
  //           "Funcionalidad de subir archivos extra aún no implementada.");
  //     },
  //     child: Container(
  //       width: 80,
  //       height: 80,
  //       decoration: BoxDecoration(
  //         border: Border.all(color: Colors.black),
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: const Center(
  //         child: Icon(Icons.add, size: 30),
  //       ),
  //     ),
  //   );
  // }

  Widget buildSwitch() {
    return Column(
      children: [
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isPublic,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    isPublic = value;
                    _checkForChanges();
                  });
                },
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              "¿Mostrar públicamente?",
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
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
                              buildTextField('Nombre del emprendimiento',
                                  businessNameController),
                              buildTextField('Nickname del emprendimiento',
                                  nicknameController),
                              buildTextField(
                                  'RUC del emprendimiento', rucController),
                              buildTextField('Nombre del representante',
                                  representativeController), // Este campo no se usa en el update actualmente
                              Row(children: [buildSwitch()]),
                              const SizedBox(height: 10),
                              const Text("Detalle del emprendimiento",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
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
                              ),
                              const SizedBox(height: 10),
                              buildTextField('Resumen del emprendimiento',
                                  summaryController),
                              buildTextField('Descripción del emprendimiento',
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
                              const Text("Modalidad del emprendimiento",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: "Presencial",
                                    groupValue: selectedModality,
                                    onChanged: (String? value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedModality = value;
                                          _checkForChanges();
                                        });
                                      }
                                    },
                                    activeColor: Colors.black,
                                  ),
                                  const Text("Presencial"),
                                  const SizedBox(width: 20),
                                  Radio<String>(
                                    value: "Virtual",
                                    groupValue: selectedModality,
                                    onChanged: (String? value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedModality = value;
                                          _checkForChanges();
                                        });
                                      }
                                    },
                                    activeColor: Colors.black,
                                  ),
                                  const Text("Virtual"),
                                ],
                              ),
                              const SizedBox(height: 20),
                              buildTextField("Dirección del emprendimiento",
                                  addressController), // Para añadir nuevas
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _addAddress,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.black),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: const Text("Agregar dirección",
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ),
                              buildAddressList(),
                              const SizedBox(height: 30),
                              const Text("Enfoque de tu emprendimiento",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 10),
                              buildTextField("Enfoque",
                                  focusController), // Para añadir nuevos
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _addFocusTag,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.black),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: const Text("Agregar enfoque",
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ),
                              const SizedBox(height: 10),
                              focusTags != []
                                  ? buildFocusTags()
                                  : Container(), // Muestra los enfoques y permite borrarlos
                              const SizedBox(height: 20),
                              const Text(
                                  "Selecciona los videos y fotos del emprendimiento",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              const Text(
                                "Ahora puedes subir hasta 3 videos de 1 minuto máximo. ¡Aprovecha esta nueva opción para mostrar mejor tu emprendimiento!",
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              // buildImageUploadButton(), // UI para "EXTRA" files
                              buildExtraFilesSection(), // UI para "EXTRA" files
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
