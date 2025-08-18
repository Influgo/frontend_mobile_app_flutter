import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:frontend_mobile_app_flutter/core/utils/platform_storage_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/gradient_bars.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:frontend_mobile_app_flutter/core/utils/image_compression_helper.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';

class Step4_5RegisterPage extends StatefulWidget {
  final Function(Uint8List) onImageCaptured;

  const Step4_5RegisterPage({super.key, required this.onImageCaptured});

  @override
  State<Step4_5RegisterPage> createState() => _Step4_5RegisterPageState();
}

class _Step4_5RegisterPageState extends State<Step4_5RegisterPage> {
  Uint8List? _capturedImageBytes;
  final Logger logger = Logger();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final imageBytes = await PlatformStorageHelper.loadImageBytes('document_back.jpg');
    if (imageBytes != null) {
      setState(() {
        _capturedImageBytes = imageBytes;
      });
    }
  }

  Future<void> _saveImage(Uint8List imageBytes) async {
    await PlatformStorageHelper.saveImageBytes('document_back.jpg', imageBytes);
  }

  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,      // Optimizado para compresión
      maxHeight: 1024,     // Optimizado para compresión
      imageQuality: 85,    // Calidad inicial
    );

    if (image != null) {
      try {
        final bytes = await image.readAsBytes();
        logger.i('DNI reverso original: ${ImageCompressionHelper.formatFileSize(bytes.length)}');
        
        // Comprimir imagen del DNI reverso
        final compressedBytes = await ImageCompressionHelper.compressImage(
          bytes, 
          fileName: 'dni_reverso.jpg'
        );
        
        await _saveImage(compressedBytes);
        setState(() {
          _capturedImageBytes = compressedBytes;
        });
        
        logger.i('DNI reverso comprimido: ${ImageCompressionHelper.formatFileSize(compressedBytes.length)}');
        
      } catch (e) {
        logger.e('Error al procesar imagen DNI reverso: $e');
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

  void validateAndContinue() {
    if (_capturedImageBytes != null) {
      logger.i(
          'La imagen reversa capturada con éxito: ${_capturedImageBytes!.length} bytes');
      widget.onImageCaptured(_capturedImageBytes!);
      RegisterPage.goToNextStep(context, image: _capturedImageBytes, step: 4);
    } else {
      logger.e('La imagen reversa es null');
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
                      'Reverso de tu documento de identidad:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _capturedImageBytes == null
                        ? Container()
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
              onPressed: _takePicture,
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
              onPressed:
                  _capturedImageBytes != null ? validateAndContinue : null,
              child: const Text(
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
