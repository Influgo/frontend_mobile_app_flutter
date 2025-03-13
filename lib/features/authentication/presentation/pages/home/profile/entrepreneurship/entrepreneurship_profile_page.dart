import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

class EntrepreneurshipProfilePage extends StatefulWidget {
  const EntrepreneurshipProfilePage({super.key});

  @override
  _EntrepreneurshipProfilePageState createState() =>
      _EntrepreneurshipProfilePageState();
}

class _EntrepreneurshipProfilePageState extends State<EntrepreneurshipProfilePage> {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController representativeController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController twitchController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController focusController = TextEditingController();

  bool isPublic = true;
  bool showInstagramField = false;
  bool showTiktokField = false;
  bool showYoutubeField = false;
  bool showTwitchField = false;
  List<String> focusTags = [];


  String? selectedCategory;
  List<String> categories = ["Comida", "Moda", "Tecnología", "Salud", "Educación"];

  String selectedModality = "Presencial";

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

  void _addFocusTag() {
    String text = focusController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        focusTags.add(text);
        focusController.clear();
      });
    }
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
              color: Color(0xFFC4C4C4),
              image: _coverImage != null
                  ? DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(_coverImage!),
                    )
                  : null,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/cameraoutlineicon.svg',
                width: 30,
                height: 30,
                color: Colors.black,
              ),
            ),
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
                backgroundColor: Color(0xFFB0B0B0), 
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
                    backgroundColor: Color(0xFFC4C4C4),
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
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
                        backgroundColor: Color(0xFFB0B0B0),
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



  Widget buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget buildFocusTags() {
    return Wrap(
      spacing: 8,
      children: focusTags.map((tag) => Chip(label: Text(tag))).toList(),
    );
  }

  Widget buildImageUploadButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(Icons.add, size: 30),
        ),
      ),
    );
  }

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
            });
          },
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          "¿Mostrar públicamente?",
          style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
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
     appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFEFEFEF), 
              borderRadius: BorderRadius.circular(8), 
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProfileSection(),
            const SizedBox(height: 50),

            buildTextField('Nombre del emprendimiento', businessNameController),
            buildTextField('Nickname del emprendimiento', nicknameController),
            buildTextField('Nombre del representante', representativeController),

            Row(children: [buildSwitch()]),
            const SizedBox(height: 10),

            const Text("Detalle del emprendimiento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),

            const Text("Categoría principal", style: TextStyle(fontSize: 14, color: Colors.black)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: "Categoría principal",
                labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
                });
              },
            ),

            const SizedBox(height: 10),

            buildTextField('Resumen del emprendimiento', summaryController),
            buildTextField('Descripción del emprendimiento', descriptionController, maxLines: 3),

            const SizedBox(height: 20),

            const Text("Redes sociales", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            buildTextField("Instagram", instagramController),
            buildTextField("Tiktok", tiktokController),
            buildTextField("Youtube", youtubeController),
            buildTextField("Twitch", twitchController),

            const SizedBox(height: 20),

            const Text("Modalidad del emprendimiento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Row(
              children: [
                Radio(
                  value: "Presencial",
                  groupValue: selectedModality,
                  onChanged: (String? value) {
                    setState(() {
                      selectedModality = value!;
                    });
                  },
                  activeColor: Colors.black,
                ),
                const Text("Presencial"),
                const SizedBox(width: 20),
                Radio(
                  value: "Virtual",
                  groupValue: selectedModality,
                  onChanged: (String? value) {
                    setState(() {
                      selectedModality = value!;
                    });
                  },
                  activeColor: Colors.black,
                ),
                const Text("Virtual"),
              ],
            ),
            const SizedBox(height: 20),
            buildTextField("Dirección del emprendimiento", addressController),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.black),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Agregar dirección", style: TextStyle(color: Colors.black)),
              ),

            ),

            const SizedBox(height: 40),
            const Text("Enfoque de tu emprendimiento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),

            buildTextField("Enfoque", focusController),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
              onPressed: _addFocusTag,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.black),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Agregar enfoque", style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 10),
            buildFocusTags(),

            const SizedBox(height: 20),
            const Text("Selecciona los videos y fotos del emprendimiento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text(
              "Ahora puedes subir hasta 3 videos de 1 minuto máximo. ¡Aprovecha esta nueva opción para mostrar mejor tu emprendimiento!",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 16),
            buildImageUploadButton(),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              ),
              child: const Text("Guardar cambios", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
      
          ],
        ),
      ),
    );
  }
}