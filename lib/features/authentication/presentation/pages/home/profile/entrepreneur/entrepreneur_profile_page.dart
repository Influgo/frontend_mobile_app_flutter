import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EntrepreneurProfilePage extends StatefulWidget {
  const EntrepreneurProfilePage({Key? key}) : super(key: key);

  @override
  _EntrepreneurProfilePageState createState() => _EntrepreneurProfilePageState();
}

class _EntrepreneurProfilePageState extends State<EntrepreneurProfilePage> {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController representativeController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();

  bool isPublic = true;
  String? selectedCategory;
  List<String> categories = ["Categoría 1", "Categoría 2", "Categoría 3"];

  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _coverImage = File(pickedFile.path);
        }
      });
    }
  }

  Widget buildProfileSection() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [

        GestureDetector(
          onTap: () => _showImagePickerDialog(false),
          child: Stack(
            alignment: Alignment.center,
            children: [
              buildImagePicker(false),
              const Positioned(
                bottom: 10,
                right: 10,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: -40,
          child: GestureDetector(
            onTap: () => _showImagePickerDialog(false),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: buildImagePicker(true),
                ),
                const Positioned(
                  bottom: 5,
                  right: 5,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 18,
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildImagePicker(bool isProfile) {
    return Container(
      width: isProfile ? 100 : double.infinity,
      height: isProfile ? 100 : 150,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: isProfile ? BoxShape.circle : BoxShape.rectangle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: _getImageProvider(isProfile),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(bool isProfile) {
    if (isProfile && _profileImage != null) {
      return FileImage(_profileImage!);
    } else if (!isProfile && _coverImage != null) {
      return FileImage(_coverImage!);
    }
    return const AssetImage('assets/placeholder.png');
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

  Widget buildTextField(String label, TextEditingController controller, {bool isFullWidth = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: isFullWidth ? double.infinity : 200,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildProfileSection(),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField('Nombre del emprendimiento', businessNameController),
                  buildTextField('Nickname del emprendimiento', nicknameController),
                  Row(
                    children: [
                      
                      Column(
                        children: [
                          const Text('Mostrar públicamente?'),
                          Switch(
                            value: isPublic,
                            onChanged: (value) {
                              setState(() {
                                isPublic = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  buildTextField('Resumen del emprendimiento', summaryController),
               
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
