import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register_page.dart';

class StepEntrepreneurRegisterPage extends StatefulWidget {
  const StepEntrepreneurRegisterPage({super.key});

  @override
  State<StepEntrepreneurRegisterPage> createState() =>
      _Step3EntrepreneurRegisterPageState();
}

class _Step3EntrepreneurRegisterPageState
    extends State<StepEntrepreneurRegisterPage> {
  File? _selectedImage;
  String? _webImagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _webImagePath = pickedFile.path;
        } else {
          _selectedImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _takePhoto() async {
    if (!kIsWeb) {
      final XFile? photo =
          await _picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capturar fotos no está disponible en Flutter Web.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double circleSize = MediaQuery.of(context).size.width * 0.5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    SvgPicture.asset(
                      'assets/images/influyo_logo.svg',
                      height: 25,
                    ),
                    const Spacer(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFC20B0C),
                                Color(0xFF7E0F9D),
                                Color(0xFF2616C7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFC20B0C),
                                Color(0xFF7E0F9D),
                                Color(0xFF2616C7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFC20B0C),
                                Color(0xFF7E0F9D),
                                Color(0xFF2616C7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Foto de registro',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Añade una foto para personalizar tu cuenta',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: circleSize + 16,
                    height: circleSize + 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_selectedImage != null || _webImagePath != null)
                          ? Color(0xFF48BA79)
                          : Colors.transparent,
                    ),
                    child: Center(
                      child: Container(
                        width: circleSize +8, 
                        height: circleSize +8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Container(
                            width: circleSize - 8,
                            height: circleSize - 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                            child: (_selectedImage == null && _webImagePath == null)
                                ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                                : ClipOval(
                                    child: kIsWeb
                                        ? Image.network(
                                            _webImagePath!,
                                            fit: BoxFit.cover,
                                            width: circleSize - 8,
                                            height: circleSize - 8,
                                          )
                                        : Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                            width: circleSize - 8,
                                            height: circleSize - 8,
                                          ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedImage != null || _webImagePath != null)
          Positioned(
            bottom: 85,
            left: 30,
            right: 30,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 24),
                side: const BorderSide(color: Colors.black, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                _pickImage();
              },
              child: const Text(
                'Tomar otra foto',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        Positioned(
          bottom: 16,
          left: 30,
          right: 30,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: (_selectedImage == null && _webImagePath == null)
                  ? Colors.grey
                  : const Color(0xFF222222),
              padding: const EdgeInsets.symmetric(vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: (_selectedImage != null || _webImagePath != null)
                ? () {
                    RegisterPage.goToNextStep(context);
                  }
                : null,
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
