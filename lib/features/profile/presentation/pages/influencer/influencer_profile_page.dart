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
  final TextEditingController bioController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController twitchController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController focusController = TextEditingController();

  // --- Nodos de Foco ---
  final FocusNode instagramFocusNode = FocusNode();
  final FocusNode facebookFocusNode = FocusNode();
  final FocusNode tiktokFocusNode = FocusNode();
  final FocusNode youtubeFocusNode = FocusNode();
  final FocusNode twitchFocusNode = FocusNode();

  // --- Variables de Estado de la UI ---
  bool showInstagramField = false;
  bool showFacebookField = false;
  bool showTiktokField = false;
  bool showYoutubeField = false;
  bool showTwitchField = false;
  List<String> focusTags = [];
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

  // --- Variables para detectar cambios ---
  bool _isDirty = false;
  String? _initialName,
      _initialNickname,
      _initialBio,
      _initialDescription,
      _initialInstagram,
      _initialFacebook,
      _initialTiktok,
      _initialYoutube,
      _initialTwitch,
      _initialSelectedCategory,
      _initialSelectedDepartment;
  bool? _initialShowCollaborations;
  List<String>? _initialFocusTags;
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
    bioController.addListener(_checkForChanges);
    descriptionController.addListener(_checkForChanges);
    instagramController.addListener(_checkForChanges);
    facebookController.addListener(_checkForChanges);
    tiktokController.addListener(_checkForChanges);
    youtubeController.addListener(_checkForChanges);
    twitchController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    // Limpiar listeners
    nameController.removeListener(_checkForChanges);
    nicknameController.removeListener(_checkForChanges);
    bioController.removeListener(_checkForChanges);
    descriptionController.removeListener(_checkForChanges);
    instagramController.removeListener(_checkForChanges);
    facebookController.removeListener(_checkForChanges);
    tiktokController.removeListener(_checkForChanges);
    youtubeController.removeListener(_checkForChanges);
    twitchController.removeListener(_checkForChanges);

    // Limpiar controladores
    nameController.dispose();
    nicknameController.dispose();
    bioController.dispose();
    descriptionController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    youtubeController.dispose();
    tiktokController.dispose();
    twitchController.dispose();
    locationController.dispose();
    focusController.dispose();
    super.dispose();
  }

  void _setInitialValues() {
    _initialName = nameController.text;
    _initialNickname = nicknameController.text;
    _initialBio = bioController.text;
    _initialDescription = descriptionController.text;
    _initialInstagram = instagramController.text;
    _initialFacebook = facebookController.text;
    _initialTiktok = tiktokController.text;
    _initialYoutube = youtubeController.text;
    _initialTwitch = twitchController.text;
    _initialSelectedCategory = selectedCategory;
    _initialSelectedDepartment = selectedDepartment;
    _initialShowCollaborations = showCollaborations;
    _initialFocusTags = List.from(focusTags);

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
    }

    bool changed = _initialName != nameController.text ||
        _initialNickname != nicknameController.text ||
        _initialBio != bioController.text ||
        _initialDescription != descriptionController.text ||
        _initialSelectedCategory != selectedCategory ||
        _initialSelectedDepartment != selectedDepartment ||
        _initialShowCollaborations != showCollaborations ||
        _profileImage != null ||
        _coverImage != null ||
        _initialInstagram != instagramController.text ||
        _initialFacebook != facebookController.text ||
        _initialTiktok != tiktokController.text ||
        _initialYoutube != youtubeController.text ||
        _initialTwitch != twitchController.text ||
        !_listEquals(_initialFocusTags, focusTags) ||
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

    // Por ahora, simulamos datos vacíos hasta que se implemente la API del influencer
    // Cuando tengas el endpoint real, reemplaza esto con la llamada HTTP correspondiente
    try {
      // Simulación de datos iniciales vacíos
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        nameController.text = '';
        nicknameController.text = '';
        bioController.text = '';
        descriptionController.text = '';
        selectedCategory = null;
        selectedDepartment = null;
        focusTags = [];
        
        // Resetear redes sociales
        showInstagramField = false;
        instagramController.clear();
        showTiktokField = false;
        showFacebookField = false;
        facebookController.clear();
        tiktokController.clear();
        showYoutubeField = false;
        youtubeController.clear();
        showTwitchField = false;
        twitchController.clear();
        
        _setInitialValues();
      });
    } catch (e) {
      print('❌ Error en fetchInfluencerData: $e');
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

  void _addFocusTag() {
    String text = focusController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        if (!focusTags.contains(text)) {
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

  Future<void> _handleSaveChanges() async {
    if (!_isDirty) {
      showSnackBar("No hay cambios para guardar.");
      return;
    }
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    // Aquí implementarías las llamadas a la API para guardar los datos del influencer
    // Por ahora simularemos un guardado exitoso
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      isSaving = false;
    });

    showSnackBar('¡Perfil actualizado con éxito!');
    _setInitialValues();
  }

  // Archivos extra
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
      _existingExtraFiles.removeWhere((f) => f['id'] == fileData['id']);
      _checkForChanges();
    });
  }

  int _getExistingFilesCount(String typeToCount) {
    return _existingExtraFiles.where((f) {
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
    String determinedFileType = "UNKNOWN";

    if (isLocal) {
      if (fileOrData is File) {
        localFile = fileOrData;
        final path = localFile.path.toLowerCase();
        determinedFileType = (path.endsWith(".mp4") || path.endsWith(".mov"))
            ? 'VIDEO'
            : 'IMAGE';
      }
    } else {
      if (fileOrData is Map<String, dynamic>) {
        remoteData = fileOrData;
        determinedFileType = remoteData['type']?.toString() ?? "UNKNOWN";
      }
    }

    if (determinedFileType == "UNKNOWN" ||
        (remoteData == null && !isLocal) ||
        (localFile == null && isLocal)) {
      return Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.error_outline, color: Colors.red, size: 30),
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
                        ),
                      )
                    : const Icon(Icons.image, size: 30))
          else if (determinedFileType == 'VIDEO')
            Icon(Icons.videocam, size: 40, color: Colors.grey[700])
          else
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
      {int maxLines = 1, FocusNode? focusNode, int? maxLength}) {
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
            maxLength: maxLength,
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
              counterText: maxLength != null ? '${controller.text.length}/$maxLength' : null,
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

  Widget buildExtraFilesSection() {
    List<Widget> fileWidgets = [];

    for (var existingFile in _existingExtraFiles) {
      fileWidgets.add(_buildExtraFileItemWidget(existingFile, false));
    }
    for (var localImage in _localExtraImages) {
      fileWidgets.add(_buildExtraFileItemWidget(localImage, true));
    }
    for (var localVideo in _localExtraVideos) {
      fileWidgets.add(_buildExtraFileItemWidget(localVideo, true));
    }

    if (_getTotalFilesCount() < _maxTotalExtraFiles) {
      fileWidgets.add(
        GestureDetector(
          onTap: () {
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
      spacing: 4.0,
      runSpacing: 4.0,
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
                              buildTextField('Nombre del Influencer', nameController),
                              buildTextField('Nickname del Influencer', nicknameController),
                              
                              DropdownButtonFormField<String>(
                                value: selectedCategory,
                                decoration: InputDecoration(
                                  labelText: "Categoría principal",
                                  labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
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
                              const SizedBox(height: 12),
                              
                              buildTextField('Resumen del influencer', bioController, maxLength: 160),
                              
                              const SizedBox(height: 20),
                              const Text("Redes sociales",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 10),
                              
                              // Instagram
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Instagram',
                                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                                  Radio<bool>(
                                    value: true,
                                    groupValue: showInstagramField,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        showInstagramField = !showInstagramField;
                                        if (!showInstagramField) {
                                          instagramController.clear();
                                        }
                                        _checkForChanges();
                                      });
                                      if (showInstagramField) {
                                        Future.delayed(const Duration(milliseconds: 100), () {
                                          FocusScope.of(context).requestFocus(instagramFocusNode);
                                        });
                                      }
                                    },
                                    activeColor: Colors.black,
                                  ),
                                ],
                              ),
                              if (showInstagramField) ...[
                                buildTextField('Cuenta de Instagram', instagramController,
                                    focusNode: instagramFocusNode),
                                const SizedBox(height: 8),
                              ],
                              const Divider(color: Colors.grey, thickness: 0.3),
                              
                              // TikTok
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tiktok',
                                      style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                                        Future.delayed(const Duration(milliseconds: 100), () {
                                          FocusScope.of(context).requestFocus(tiktokFocusNode);
                                        });
                                      }
                                    },
                                    activeColor: Colors.black,
                                  ),
                                ],
                              ),
                              if (showTiktokField) ...[
                                buildTextField('Usuario de Tiktok', tiktokController,
                                    focusNode: tiktokFocusNode),
                                const SizedBox(height: 8),
                              ],
                              const Divider(color: Colors.grey, thickness: 0.3),
                              
                              // Otras redes sociales opcionales
                              const Text("Otras redes sociales (opcional)",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              
                              // YouTube
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Youtube',
                                      style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                                    },
                                    activeColor: Colors.black,
                                  ),
                                ],
                              ),
                              if (showYoutubeField) ...[
                                buildTextField('Canal de Youtube', youtubeController),
                                const SizedBox(height: 8),
                              ],
                              
                              // Twitch
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Twitch',
                                      style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                                    },
                                    activeColor: Colors.black,
                                  ),
                                ],
                              ),
                              if (showTwitchField) ...[
                                buildTextField('Canal de Twitch', twitchController),
                                const SizedBox(height: 8),
                              ],
                              
                              const SizedBox(height: 20),
                              buildTextField('Descripción del influencer', descriptionController,
                                  maxLines: 3, maxLength: 500),
                              
                              const SizedBox(height: 20),
                              const Text("Ubicación",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 10),
                              
                              DropdownButtonFormField<String>(
                                value: selectedDepartment,
                                decoration: InputDecoration(
                                  labelText: "Departamento donde resides",
                                  labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 12),
                                ),
                                items: departments.map((String department) {
                                  return DropdownMenuItem<String>(
                                    value: department,
                                    child: Text(department),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedDepartment = newValue;
                                    _checkForChanges();
                                  });
                                },
                                hint: const Text('Seleccione un departamento'),
                              ),
                              
                              const SizedBox(height: 30),
                              const Text("Enfoque de tu perfil",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 10),
                              buildTextField("Enfoque", focusController),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _addFocusTag,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.black),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text("Agregar enfoque",
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (focusTags.isNotEmpty) buildFocusTags(),
                              
                              const SizedBox(height: 20),
                              const Text("Selecciona los videos y fotos de tu contenido",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              const Text(
                                "Ahora puedes subir hasta 3 videos de 1 minuto máximo e imágenes de máximo 5MB. ¡Muestra tu trabajo y destaca tu impacto en las marcas!",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              buildExtraFilesSection(),
                              
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
                                  onPressed: (_isDirty && !isSaving) ? _handleSaveChanges : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (_isDirty && !isSaving) ? Colors.black : Colors.grey,
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text("Guardar cambios",
                                          style: TextStyle(color: Colors.white, fontSize: 16)),
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