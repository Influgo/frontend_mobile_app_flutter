import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/gradient_bars.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/data/models/validation_data.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step6.5_images_validated.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step6.5_images_not_validated.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Step6RegisterPage extends StatefulWidget {
  final Function(Uint8List) onImageCaptured;
  final ValidationData validationData;

  const Step6RegisterPage({
    super.key,
    required this.onImageCaptured,
    required this.validationData,
  });

  @override
  State<Step6RegisterPage> createState() => _Step6RegisterPageState();
}

class _Step6RegisterPageState extends State<Step6RegisterPage> {
  Uint8List? _capturedImageBytes;
  final Logger logger = Logger();
  final AuthRemoteDataSource authRemoteDataSource =
      AuthRemoteDataSourceImpl(client: http.Client());
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/selfie_register.jpg';
    final imageFile = File(imagePath);
    if (await imageFile.exists()) {
      final imageBytes = await imageFile.readAsBytes();
      setState(() {
        _capturedImageBytes = imageBytes;
      });
    }
  }

  Future<void> _saveImage(Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/selfie_register.jpg';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(imageBytes);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (image != null) {
      final imageBytes = await image.readAsBytes();
      await _saveImage(imageBytes);
      setState(() {
        _capturedImageBytes = imageBytes;
      });
      logger.i('Foto de perfil capturada: ${imageBytes.length} bytes');
    }
  }

  Future<String> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email_register') ?? '';
  }

  Future<void> validateAndContinue() async {
    if (_capturedImageBytes == null) {
      logger.e('Foto de perfil es null');
      return;
    }

    setState(() {
      _isValidating = true;
    });

    try {
      logger.i('Iniciando validación de imágenes...');

      // Obtener email del usuario
      final userEmail = await _getUserEmail();

      if (userEmail.isEmpty) {
        logger.e('Email del usuario no encontrado');
        setState(() {
          _isValidating = false;
        });
        return;
      }

      // Actualizar ValidationData con la imagen del perfil
      final updatedValidationData = ValidationData(
        anversoImage: widget.validationData.anversoImage,
        reversoImage: widget.validationData.reversoImage,
        perfilImage: _capturedImageBytes,
      );

      // Llamar al callback con la imagen capturada
      widget.onImageCaptured(_capturedImageBytes!);

      // Validar imágenes
      await authRemoteDataSource.validateImages(
        userIdentifier: userEmail,
        documentFrontImage: updatedValidationData.anversoImage!,
        documentBackImage: updatedValidationData.reversoImage!,
        profileImage: updatedValidationData.perfilImage!,
      );

      logger.i('Validación de imágenes exitosa');

      // Navegar a página de validación exitosa
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Step65ImagesValidatedPage(
              validationData: updatedValidationData,
            ),
          ),
        );
      }
    } catch (e) {
      logger.e('Error en la validación de imágenes: $e');

      // Navegar a página de validación fallida
      if (mounted) {
        final updatedValidationData = ValidationData(
          anversoImage: widget.validationData.anversoImage,
          reversoImage: widget.validationData.reversoImage,
          perfilImage: _capturedImageBytes,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Step65ImagesNotValidatedPage(
              validationData: updatedValidationData,
              errorMessage: e.toString(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
            child: Column(
              children: [
                const InfluyoLogo(),
                GradientBars(barCount: 3),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Foto de registro:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tome una foto de su rostro',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _capturedImageBytes == null
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'No hay foto',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.memory(
                              _capturedImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Positioned(
            bottom: 96,
            left: 30,
            right: 30,
            child: ElevatedButton(
              onPressed: _isValidating ? null : _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF222222),
                padding: const EdgeInsets.symmetric(vertical: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(
                _capturedImageBytes == null ? 'Tomar Foto' : 'Tomar otra foto',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 30,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF222222),
                padding: const EdgeInsets.symmetric(vertical: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: (_capturedImageBytes != null && !_isValidating)
                  ? validateAndContinue
                  : null,
              child: _isValidating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Continuar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
