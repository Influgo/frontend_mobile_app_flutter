import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/gradient_bars.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:logger/logger.dart';

class Step4RegisterPage extends StatefulWidget {
  final Function(Uint8List) onImageCaptured;

  const Step4RegisterPage({super.key, required this.onImageCaptured});

  @override
  State<Step4RegisterPage> createState() => _Step4RegisterPageState();
}

class _Step4RegisterPageState extends State<Step4RegisterPage> {
  CameraController? _cameraController;
  Uint8List? _capturedImageBytes;
  bool _isCameraInitialized = false;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await _cameraController!.initialize();
      await _cameraController!
          .lockCaptureOrientation(DeviceOrientation.portraitUp);
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void validateAndContinue() {
    if (_capturedImageBytes != null) {
      logger.i(
          'La imagen anversa capturada con exito: ${_capturedImageBytes!.length} bytes');
      widget.onImageCaptured(_capturedImageBytes!);
      RegisterPage.goToNextStep(context, image: _capturedImageBytes, step: 4);
    } else {
      logger.e('La imagen anversa es null');
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
                      'Anverso de tu documento de identidad:',
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
                        ? _isCameraInitialized
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Transform.rotate(
                                  angle: 1.5708,
                                  child: CameraPreview(_cameraController!),
                                ),
                              )
                            : const Center(
                                child: CircularProgressIndicator(),
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
              onPressed: () async {
                if (_cameraController != null &&
                    _cameraController!.value.isInitialized) {
                  if (_capturedImageBytes == null) {
                    final image = await _cameraController!.takePicture();
                    final bytes = await image.readAsBytes();
                    setState(() {
                      _capturedImageBytes = bytes;
                    });
                    logger.i(
                        'La imagen anversa capturada: ${bytes.length} bytes');
                  } else {
                    setState(() {
                      _capturedImageBytes = null;
                      _initializeCamera();
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _capturedImageBytes == null
                    ? const Color(0xFF222222)
                    : const Color(0xFF222222),
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
