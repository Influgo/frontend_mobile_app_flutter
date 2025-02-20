import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/gradient_bars.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:logger/logger.dart';

class Step6RegisterPage extends StatefulWidget {
  final Function(Uint8List) onImageCaptured;
  const Step6RegisterPage({super.key, required this.onImageCaptured});

  @override
  State<Step6RegisterPage> createState() => _Step6RegisterPageState();
}

class _Step6RegisterPageState extends State<Step6RegisterPage> {
  Uint8List? _capturedImageBytes;
  final Logger logger = Logger();

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

  void validateAndContinue() {
    if (_capturedImageBytes != null) {
      logger.i('Foto de perfil lista para enviar');
      widget.onImageCaptured(_capturedImageBytes!);
      RegisterPage.goToNextStep(context, image: _capturedImageBytes, step: 6);
    } else {
      logger.e('Foto de perfil es null');
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
              onPressed: _pickImage,
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
