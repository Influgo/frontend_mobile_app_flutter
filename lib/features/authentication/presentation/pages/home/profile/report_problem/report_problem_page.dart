import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/report_problem/report_success_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReportProblemPage extends StatefulWidget {
  const ReportProblemPage({super.key});

  @override
  _ReportProblemPageState createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final TextEditingController _descriptionController = TextEditingController();
  int _charCount = 0;
  final List<File> _images = [];
  final int _maxImages = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {
        _charCount = _descriptionController.text.length;
      });
    });
  }

  Future<void> _pickImage() async {
    if (_images.length >= _maxImages) return;

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _submitReport() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa una descripción')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No se encontró el token de autenticación');
      }

      // 1. Crear el reporte (primer endpoint)
      final reportResponse = await http.post(
        Uri.parse('https://influyo-testing.ryzeon.me/api/v1/entities/reports'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reportDescription': _descriptionController.text,
        }),
      );

      if (reportResponse.statusCode != 200) {
        throw Exception('Error al crear el reporte: ${reportResponse.body}');
      }

      final reportData = jsonDecode(reportResponse.body);
      final reportId = reportData['id'];

      // 2. Subir imágenes solo si estamos en una plataforma con dart:io
      if (_images.isNotEmpty) {
        // Verificar si estamos en una plataforma que soporta dart:io
        if (!Platform.isAndroid &&
            !Platform.isIOS &&
            !Platform.isLinux &&
            !Platform.isMacOS &&
            !Platform.isWindows) {
          throw Exception(
              'La subida de archivos no está soportada en esta plataforma');
        }

        for (final image in _images) {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse(
                'https://influyo-testing.ryzeon.me/api/v1/entities/reports/upload/$reportId'),
          );
          request.headers['Authorization'] = 'Bearer $token';

          // Crear el MultipartFile de manera segura
          final file = await http.MultipartFile.fromPath(
            'file',
            image.path,
          );
          request.files.add(file);

          final uploadResponse = await request.send();
          if (uploadResponse.statusCode != 200) {
            throw Exception(
                'Error al subir imagen: ${uploadResponse.reasonPhrase}');
          }
        }
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportSuccessPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text(
          'Reportar un problema',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descripción',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text('Describe el problema con claridad.',
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            SizedBox(height: 8),
            Container(
              height: 338,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: "Describe tu problema",
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text('$_charCount/500',
                        style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('Subir Fotos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text(
                'Puedes adjuntar 3 fotos como máximo para ilustrar el problema.',
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 80,
                    height: 161,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, size: 30, color: Colors.black54),
                  ),
                ),
                SizedBox(width: 8),
                ..._images.asMap().entries.map((entry) {
                  int index = entry.key;
                  File image = entry.value;
                  return Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 161,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: FileImage(image), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                color: Colors.black54, shape: BoxShape.circle),
                            child: Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Enviar reporte',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
