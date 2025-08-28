import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/gradient_bars.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/data/models/validation_data.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step6.5_images_validated.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step6.5_images_not_validated.dart';
import 'package:frontend_mobile_app_flutter/core/utils/image_compression_helper.dart';
import 'package:frontend_mobile_app_flutter/core/utils/platform_storage_helper.dart';
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
    final imageBytes = await PlatformStorageHelper.loadImageBytes('selfie_register.jpg');
    if (imageBytes != null) {
      setState(() {
        _capturedImageBytes = imageBytes;
      });
    }
  }

  Future<void> _saveImage(Uint8List imageBytes) async {
    await PlatformStorageHelper.saveImageBytes('selfie_register.jpg', imageBytes);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1024,      // Optimizado para mejor compresión
      maxHeight: 1024,     // Optimizado para mejor compresión
      imageQuality: 85,    // Calidad inicial para reducir tamaño
    );

    if (image != null) {
      try {
        final imageBytes = await image.readAsBytes();
        logger.i('Imagen original capturada: ${ImageCompressionHelper.formatFileSize(imageBytes.length)}');
        
        // Comprimir imagen automáticamente
        final compressedBytes = await ImageCompressionHelper.compressImage(
          imageBytes, 
          fileName: 'selfie_register.jpg'
        );
        
        // Validar tamaño final
        final imageInfo = ImageCompressionHelper.getImageInfo(compressedBytes);
        logger.i('Imagen final: ${imageInfo['sizeInMB']}MB (válida: ${imageInfo['isValid']})');
        
        await _saveImage(compressedBytes);
        setState(() {
          _capturedImageBytes = compressedBytes;
        });
        
        // Mostrar información al usuario si la imagen fue comprimida significativamente
        if (imageBytes.length > compressedBytes.length) {
          final compressionRatio = ((imageBytes.length - compressedBytes.length) / imageBytes.length * 100);
          if (compressionRatio > 20) { // Si se redujo más del 20%
            logger.i('Imagen comprimida: ${compressionRatio.toStringAsFixed(1)}% de reducción');
          }
        }
        
      } catch (e) {
        logger.e('Error al procesar imagen: $e');
        // Mostrar error al usuario
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al procesar la imagen. Intente nuevamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<String> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email_register') ?? '';
  }

  Future<String> _getUserDni() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('dni_register') ?? '';
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
      logger.i('Iniciando validación de imágenes con nuevo endpoint AWS Lambda...');

      // Obtener DNI del usuario
      final userDni = await _getUserDni();

      if (userDni.isEmpty) {
        logger.e('DNI del usuario no encontrado');
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

      // Verificar que todas las imágenes necesarias estén disponibles
      if (updatedValidationData.anversoImage == null) {
        logger.e('Imagen del anverso del documento no disponible');
        throw Exception('Imagen del documento frontal no disponible. Por favor, regrese al paso anterior.');
      }

      if (updatedValidationData.perfilImage == null) {
        logger.e('Imagen del perfil no disponible');
        throw Exception('Imagen del perfil no disponible. Por favor, tome la foto nuevamente.');
      }

      logger.i('Verificando imágenes - Anverso: ${updatedValidationData.anversoImage!.length} bytes, Perfil: ${updatedValidationData.perfilImage!.length} bytes');

      // Llamar al callback con la imagen capturada
      widget.onImageCaptured(_capturedImageBytes!);

      // Validar imágenes con nuevo endpoint (solo foto frontal del documento)
      final validationResponse = await authRemoteDataSource.validateImages(
        dni: userDni,
        documentFrontImage: updatedValidationData.anversoImage!,
        profileImage: updatedValidationData.perfilImage!,
      );

      logger.i('Validación completada. Respuesta: $validationResponse');

      // Validar que la respuesta no sea null y tenga la estructura esperada
      if (validationResponse == null || validationResponse is! Map<String, dynamic>) {
        logger.e('La respuesta de validación es null o no tiene el formato esperado');
        throw Exception('Respuesta de validación inválida del servidor');
      }

      // Verificar el campo 'match' del backend para determinar si la validación fue exitosa
      logger.i('Estructura completa de la respuesta: ${validationResponse.toString()}');
      
      // Verificación segura del campo 'match' con null safety
      final matchValue = validationResponse['match'];
      bool isValidationSuccessful = false;
      
      if (matchValue != null) {
        isValidationSuccessful = matchValue == true;
        logger.i('Campo match encontrado: $matchValue');
      } else {
        logger.w('Campo match no encontrado en la respuesta o es null');
        logger.w('Campos disponibles en la respuesta: ${validationResponse.keys.toList()}');
      }

      logger.i('¿Validación exitosa? $isValidationSuccessful');

      if (mounted) {
        if (isValidationSuccessful) {
          // Navegar a página de validación exitosa
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Step65ImagesValidatedPage(
                validationData: updatedValidationData,
              ),
            ),
          );
        } else {
          // Navegar a página de validación fallida
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Step65ImagesNotValidatedPage(
                validationData: updatedValidationData,
                errorMessage: 'La validación no alcanzó el umbral requerido de similaridad',
              ),
            ),
          );
        }
      }
    } catch (e) {
      logger.e('Error en la validación de imágenes: $e');
      logger.e('Stack trace: ${StackTrace.current}');

      // Navegar a página de validación fallida
      if (mounted) {
        final updatedValidationData = ValidationData(
          anversoImage: widget.validationData.anversoImage,
          reversoImage: widget.validationData.reversoImage,
          perfilImage: _capturedImageBytes,
        );

        // Crear un mensaje de error más descriptivo
        String errorMessage = 'Error de conexión durante la validación';
        if (e.toString().contains('ServerException')) {
          errorMessage = 'Error del servidor durante la validación de imágenes';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = 'Error de conexión a internet durante la validación';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Timeout durante la validación de imágenes';
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Step65ImagesNotValidatedPage(
              validationData: updatedValidationData,
              errorMessage: errorMessage,
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
