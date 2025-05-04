import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/card_info_widget.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/section_title_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/remuneration_switch_widget.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController representativeController =
      TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController focusController = TextEditingController();

  bool isPublic = false;

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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.only(top: 16),
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => _showImagePickerDialog(false),
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xFFC4C4C4),
                borderRadius: BorderRadius.circular(5),
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
            bottom: 15,
            child: GestureDetector(
              onTap: () => _showImagePickerDialog(false),
              child: CircleAvatar(
                radius: 5,
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
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
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
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Icon(Icons.add, size: 30),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
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
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Crear evento',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Información general",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            buildProfileSection(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  buildTextField('Nombre del evento', eventNameController),
                  buildTextField(
                      'Descripción del evento', descriptionController,
                      maxLines: 3),
                  const Text("Detalles del evento",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  buildTextField(
                      'Fecha del emprendimiento', nicknameController),
                  Row(
                    children: [
                      Expanded(
                        child:
                            buildTextField('Hora inicio', nicknameController),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: buildTextField('Hora fin', nicknameController),
                      ),
                    ],
                  ),
                  SectionTitleWidget("Tipo de publicidad"),
                  CardInfoWidget(
                    title: "Publicidad virtual",
                    subtitle:
                        "Publicidad que se puede realizar desde cualquier lugar (no requiere la presencia física del influencer).",
                  ),
                  const SizedBox(height: 10),
                  SectionTitleWidget("Trabajo a realizar y Participación"),
                  buildTextField('Trabajo a realizar', nicknameController),
                  buildTextField('Remuneración', nicknameController),
                  Row(children: [
                    RemunerationSwitchWidget(
                      isPublic: isPublic,
                      onChanged: (value) {
                        setState(() {
                          isPublic = value;
                        });
                      },
                    ),
                  ]),
                  buildTextField('Cant. de participantes', nicknameController),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // : Colors.grey,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
