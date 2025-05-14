import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EntrepreneurshipProfilePage extends StatefulWidget {
  const EntrepreneurshipProfilePage({super.key});

  @override
  _EntrepreneurshipProfilePageState createState() =>
      _EntrepreneurshipProfilePageState();
}

Widget ErrorTextWidget({required String error}) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Text(
      error,
      style: const TextStyle(color: Colors.red, fontSize: 12),
    ),
  );
}

class _EntrepreneurshipProfilePageState
    extends State<EntrepreneurshipProfilePage> {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController representativeController =
      TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController twitchController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController focusController = TextEditingController();
  final TextEditingController rucController = TextEditingController();

  final FocusNode instagramFocusNode = FocusNode();
  final FocusNode tiktokFocusNode = FocusNode();
  final FocusNode youtubeFocusNode = FocusNode();
  final FocusNode twitchFocusNode = FocusNode();

  bool isPublic = true;
  bool showInstagramField = false;
  bool showTiktokField = false;
  bool showYoutubeField = false;
  bool showTwitchField = false;
  List<String> focusTags = [];
  List<String> addressList = [];

  String? socialMediaEmpty;
  String? instagramEmpty;
  String? tiktokEmpty;
  String? youtubeEmpty;
  String? twitchEmpty;

  String? selectedCategory;
  List<String> categories = [
    "Comida",
    "Moda",
    "Tecnología",
    "Salud",
    "Educación"
  ];

  String selectedModality = "Presencial";

  bool isLoading = false;
  bool isSaving = false;
  String? token;
  int? entrepreneurId;

  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inicializar isPublic explícitamente para asegurar que nunca sea null
    isPublic = true;
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        token = prefs.getString('token');
        // Podríamos obtener el entrepreneurId de SharedPreferences si está almacenado
        // O bien podemos obtenerlo al cargar el perfil desde el API
      });

      // Aquí podrías cargar datos actuales si es necesario
      // fetchEntrepreneurData();
    } catch (e) {
      print('❌ Error cargando token: $e');
      showSnackBar('Error al cargar datos de autenticación');
    }
  }

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

  void _addAddress() {
    String address = addressController.text.trim();
    if (address.isNotEmpty) {
      setState(() {
        addressList.add(address);
        addressController.clear();
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

  Future<bool> saveEntrepreneurshipProfile() async {
    setState(() {
      isSaving = true;
    });

    try {
      final url = Uri.parse(
          'https://influyo-testing.ryzeon.me/api/v1/entities/entrepreneur/update');

      // Asegurar que isPublic no sea null
      if (isPublic == null) {
        isPublic = false; // Valor por defecto si de alguna manera es null
      }

      // Construir el cuerpo de la petición
      final Map<String, dynamic> body = {
        // Siempre incluir showOwnerName de forma explícita con un valor booleano
        'showOwnerName': isPublic
      };

      print('🔍 Valor de isPublic: $isPublic');
      print('🔍 Tipo de isPublic: ${isPublic.runtimeType}');

      // ID del emprendedor (esto debe venir del backend o de SharedPreferences)
      if (entrepreneurId != null) {
        body['id'] = entrepreneurId;
      }

      if (businessNameController.text.isNotEmpty) {
        body['entrepreneurshipInformationEntrepreneurshipName'] =
            businessNameController.text;
      }

      if (nicknameController.text.isNotEmpty) {
        body['entrepreneurshipInformationEntrepreneursNickname'] =
            nicknameController.text;
      }

      if (rucController.text.isNotEmpty) {
        body['entrepreneurshipInformationEntrepreneurshipRUC'] =
            rucController.text;
      }

      if (selectedCategory != null) {
        body['entrepreneurshipInformationCategory'] = selectedCategory;
      }

      if (summaryController.text.isNotEmpty) {
        body['entrepreneurshipInformationSummary'] = summaryController.text;
      }

      if (descriptionController.text.isNotEmpty) {
        body['entrepreneurshipInformationDescription'] =
            descriptionController.text;
      }

      // Tipo de dirección (modalidad)
      if (selectedModality.isNotEmpty) {
        body['entrepreneurAddressAddressType'] = selectedModality;
      }

      // Enfoques (etiquetas)
      if (focusTags.isNotEmpty) {
        body['entrepreneurFocus'] = focusTags;
      }

      // Direcciones
      if (addressList.isNotEmpty) {
        body['entrepreneurAddresses'] = addressList;
      }

      // Información de redes sociales si están habilitadas
      Map<String, dynamic> socials = {};

      if (showInstagramField && instagramController.text.isNotEmpty) {
        socials['instagram'] = instagramController.text;
      }

      if (showTiktokField && tiktokController.text.isNotEmpty) {
        socials['tiktok'] = tiktokController.text;
      }

      if (showYoutubeField && youtubeController.text.isNotEmpty) {
        socials['youtube'] = youtubeController.text;
      }

      if (showTwitchField && twitchController.text.isNotEmpty) {
        socials['twitch'] = twitchController.text;
      }

      if (socials.isNotEmpty) {
        body['socials'] = socials;
      }

      print('📤 Actualizando perfil de emprendimiento');
      print('📤 URL: $url');
      print('📤 Body: ${jsonEncode(body)}');

      // Ver si hay algún problema en la serialización JSON
      String bodyJson = jsonEncode(body);
      print('📤 Body JSON serializado: $bodyJson');

      // Comprobar si showOwnerName existe en el JSON y es de tipo booleano
      Map<String, dynamic> decodedBody = jsonDecode(bodyJson);
      print('📤 showOwnerName en JSON: ${decodedBody['showOwnerName']}');
      print(
          '📤 Tipo de showOwnerName en JSON: ${decodedBody['showOwnerName'].runtimeType}');

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: bodyJson,
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Perfil actualizado con éxito');
        return true;
      } else {
        print(
            '❌ Error al actualizar el perfil. Código: ${response.statusCode}');
        print('❌ Respuesta: ${response.body}');
        showSnackBar(
            'Error al actualizar el perfil: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      showSnackBar('Error de conexión: $e');
      return false;
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
              color: const Color(0xFFC4C4C4),
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
                backgroundColor: const Color(0xFFB0B0B0),
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
                    backgroundColor: const Color(0xFFC4C4C4),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
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
                        backgroundColor: const Color(0xFFB0B0B0),
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

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, FocusNode? focusNode}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget buildFocusTags() {
    return Wrap(
      spacing: 8,
      children: focusTags
          .map((tag) => Chip(
                label: Text(tag),
                onDeleted: () {
                  setState(() {
                    focusTags.remove(tag);
                  });
                },
              ))
          .toList(),
    );
  }

  Widget buildAddressList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (addressList.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            "Direcciones agregadas:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 5),
          ...addressList
              .map((address) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(address),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 18, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              addressList.remove(address);
                            });
                          },
                        ),
                      ],
                    ),
                  ))
              .toList(),
          const SizedBox(height: 10),
        ],
      ],
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
        child: const Center(
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
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildProfileSection(),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTextField('Nombre del emprendimiento',
                            businessNameController),
                        buildTextField(
                            'Nickname del emprendimiento', nicknameController),
                        buildTextField('RUC del emprendimiento', rucController),
                        buildTextField('Nombre del representante',
                            representativeController),
                        Row(children: [buildSwitch()]),
                        const SizedBox(height: 10),
                        const Text("Detalle del emprendimiento",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: InputDecoration(
                            labelText: "Categoría principal",
                            labelStyle: const TextStyle(
                                fontSize: 14, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
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
                          hint: const Text('Seleccione una categoría'),
                        ),
                        const SizedBox(height: 10),
                        buildTextField(
                            'Resumen del emprendimiento', summaryController),
                        buildTextField('Descripción del emprendimiento',
                            descriptionController,
                            maxLines: 3),
                        const SizedBox(height: 20),
                        const Text("Redes sociales",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Instagram',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            Radio<bool>(
                              value: true,
                              groupValue: showInstagramField ? true : null,
                              onChanged: (bool? value) {
                                setState(() {
                                  showInstagramField = !showInstagramField;
                                });
                                if (showInstagramField) {
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    FocusScope.of(context)
                                        .requestFocus(instagramFocusNode);
                                  });
                                }
                              },
                              activeColor: Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (showInstagramField) ...[
                          buildTextField(
                              'Cuenta de Instagram', instagramController,
                              focusNode: instagramFocusNode),
                          if (instagramEmpty != null)
                            ErrorTextWidget(error: instagramEmpty!),
                          const SizedBox(height: 8),
                        ],
                        const Divider(color: Colors.grey, thickness: 0.3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tiktok',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            Radio<bool>(
                              value: true,
                              groupValue: showTiktokField ? true : null,
                              onChanged: (bool? value) {
                                setState(() {
                                  showTiktokField = !showTiktokField;
                                });
                                if (showTiktokField) {
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    FocusScope.of(context)
                                        .requestFocus(tiktokFocusNode);
                                  });
                                }
                              },
                              activeColor: Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (showTiktokField) ...[
                          buildTextField('Usuario de Tiktok', tiktokController,
                              focusNode: tiktokFocusNode),
                        ],
                        const SizedBox(height: 16),
                        const Text('Otras redes sociales (opcional)',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Youtube',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            Radio<bool>(
                              value: true,
                              groupValue: showYoutubeField ? true : null,
                              onChanged: (bool? value) {
                                setState(() {
                                  showYoutubeField = !showYoutubeField;
                                });
                                if (showYoutubeField) {
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    FocusScope.of(context)
                                        .requestFocus(youtubeFocusNode);
                                  });
                                }
                              },
                              activeColor: Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (showYoutubeField) ...[
                          buildTextField('Canal de Youtube', youtubeController,
                              focusNode: youtubeFocusNode),
                        ],
                        const Divider(color: Colors.grey, thickness: 0.3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Twitch',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            Radio<bool>(
                              value: true,
                              groupValue: showTwitchField ? true : null,
                              onChanged: (bool? value) {
                                setState(() {
                                  showTwitchField = !showTwitchField;
                                });
                                if (showTwitchField) {
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    FocusScope.of(context)
                                        .requestFocus(twitchFocusNode);
                                  });
                                }
                              },
                              activeColor: Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (showTwitchField) ...[
                          buildTextField('Canal de Twitch', twitchController,
                              focusNode: twitchFocusNode),
                        ],
                        const SizedBox(height: 20),
                        const Text("Modalidad del emprendimiento",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
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
                        buildTextField(
                            "Dirección del emprendimiento", addressController),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.black),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text("Agregar dirección",
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        buildAddressList(),
                        const SizedBox(height: 40),
                        const Text("Enfoque de tu emprendimiento",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        buildTextField("Enfoque", focusController),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addFocusTag,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.black),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text("Agregar enfoque",
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildFocusTags(),
                        const SizedBox(height: 20),
                        const Text(
                            "Selecciona los videos y fotos del emprendimiento",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
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
                            onPressed: isSaving
                                ? null
                                : () async {
                                    bool success =
                                        await saveEntrepreneurshipProfile();
                                    if (success) {
                                      showSnackBar(
                                          'Perfil actualizado con éxito');
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        Navigator.pop(context);
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Guardar cambios",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child:
                      Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
