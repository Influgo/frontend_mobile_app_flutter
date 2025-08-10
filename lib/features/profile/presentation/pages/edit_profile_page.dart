import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({super.key, required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController documentController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? profileImageUrl;
  File? newProfileImage;
  String? token;
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;
  bool showSuccessMessage = false;

  // Initial values to check if edited
  String? initialName,
      initialLastName,
      initialDocument,
      initialEmail,
      initialPhone;
  String? documentType;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');

      if (token != null) {
        fetchUserData();
      } else {
        setState(() {
          isLoading = false;
        });
        showSnackBar('No se encontró el token de autenticación');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading token: $e');
      showSnackBar('Error al cargar datos de autenticación');
    }
  }

  Future<void> fetchUserData() async {
    final String url =
        'https://influyo-testing.ryzeon.me/api/v1/account/${widget.userId}';

    print('📥 Solicitando datos del usuario: ${widget.userId}');
    print('📥 URL: $url');
    print('📥 Token disponible: ${token != null ? 'Sí' : 'No'}');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📥 Datos obtenidos: $data');

        setState(() {
          // Set controllers with data from API
          initialName = nameController.text = data['names'] ?? '';
          initialLastName = lastNameController.text = data['lastNames'] ?? '';

          if (data['identification'] != null) {
            initialDocument = documentController.text =
                data['identification']['number'] ?? '';
            documentType = data['identification']['type'] ?? '';
            print('📥 Documento: $documentType - $initialDocument');
          }

          initialEmail = emailController.text = data['email'] ?? '';
          initialPhone = phoneController.text = data['phoneNumber'] ?? '';

          // Profile image URL
          if (data['profileImage'] != null &&
              data['profileImage']['url'] != null) {
            profileImageUrl = data['profileImage']['url'];
            print('📥 Imagen de perfil: $profileImageUrl');
          }

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('❌ Error al obtener los datos. Código: ${response.statusCode}');
        print('❌ Respuesta: ${response.body}');
        showSnackBar(
            'Error al obtener los datos: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('❌ Error fetchUserData: $e');
      showSnackBar('Error de conexión: $e');
    }
  }

  void checkForChanges() {
    setState(() {
      isEditing = nameController.text != initialName ||
          lastNameController.text != initialLastName ||
          documentController.text != initialDocument ||
          emailController.text != initialEmail ||
          phoneController.text != initialPhone ||
          newProfileImage != null;
    });
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Reduce quality a bit to decrease file size
        maxWidth: 1000, // Limit width
        maxHeight: 1000, // Limit height
      );

      if (image != null) {
        print('📷 Imagen seleccionada: ${image.path}');
        print('📷 Nombre: ${image.name}');

        // Get file info
        final File file = File(image.path);
        final int fileSize = await file.length();
        print('📷 Tamaño: ${(fileSize / 1024).toStringAsFixed(2)} KB');

        setState(() {
          newProfileImage = file;
          isEditing = true;
        });
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      showSnackBar('Error al seleccionar imagen: $e');
    }
  }

  Future<bool> uploadProfileImage() async {
    if (newProfileImage == null) return true; // No new image to upload

    try {
      final url = Uri.parse(
          'https://influyo-testing.ryzeon.me/api/v1/account/upload-profile-image');

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // Log request info
      print('📤 Subiendo imagen: ${newProfileImage!.path}');
      print('📤 URL: $url');
      print('📤 Headers: ${request.headers}');

      // Probar con el nombre de campo 'image'
      var fieldName = 'image';
      var file = await http.MultipartFile.fromPath(
        fieldName,
        newProfileImage!.path,
      );

      print('📤 File field name: ${file.field}');
      print('📤 File name: ${file.filename}');
      print('📤 File content type: ${file.contentType}');
      print('📤 File length: ${file.length}');

      request.files.add(file);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📥 Parsed response data: $data');

        // Update profileImageUrl with new URL
        if (data['url'] != null) {
          setState(() {
            profileImageUrl = data['url'];
          });
          print('✅ Imagen actualizada con éxito: $profileImageUrl');
        }
        return true;
      } else if (response.statusCode == 400) {
        // Si falla con 'image', intentar con 'file'
        print('❌ Falló con campo "$fieldName", intentando con "file"');

        request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $token';

        file = await http.MultipartFile.fromPath(
          'file',
          newProfileImage!.path,
        );

        request.files.add(file);

        streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);

        print('📥 Segundo intento - status code: ${response.statusCode}');
        print('📥 Segundo intento - body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['url'] != null) {
            setState(() {
              profileImageUrl = data['url'];
            });
            print(
                '✅ Imagen actualizada con éxito en segundo intento: $profileImageUrl');
          }
          return true;
        } else {
          // Si ninguno funciona, intentar con 'profileImage'
          print('❌ Falló con campo "file", intentando con "profileImage"');

          request = http.MultipartRequest('POST', url);
          request.headers['Authorization'] = 'Bearer $token';

          file = await http.MultipartFile.fromPath(
            'profileImage',
            newProfileImage!.path,
          );

          request.files.add(file);

          streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);

          print('📥 Tercer intento - status code: ${response.statusCode}');
          print('📥 Tercer intento - body: ${response.body}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            if (data['url'] != null) {
              setState(() {
                profileImageUrl = data['url'];
              });
              print(
                  '✅ Imagen actualizada con éxito en tercer intento: $profileImageUrl');
            }
            return true;
          } else {
            print('❌ Todos los intentos fallaron para subir imagen');
            showSnackBar(
                'Error al subir la imagen: ${response.statusCode} - ${response.body}');
            return false;
          }
        }
      } else {
        print('❌ Error al subir la imagen. Código: ${response.statusCode}');
        print('❌ Respuesta: ${response.body}');
        showSnackBar(
            'Error al subir la imagen: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      showSnackBar('Error al subir la imagen: $e');
      return false;
    }
  }

  Future<bool> updateUserInfo() async {
    // Check if there are changes in the text fields
    if (nameController.text == initialName &&
        lastNameController.text == initialLastName &&
        documentController.text == initialDocument &&
        emailController.text == initialEmail &&
        phoneController.text == initialPhone) {
      return true; // No changes to update
    }

    final String url =
        'https://influyo-testing.ryzeon.me/api/v1/account/${widget.userId}';

    // Enviar todos los campos, no solo los que cambiaron
    // Ya que el backend parece requerir todos los campos incluso en PATCH
    final Map<String, dynamic> body = {
      'names': nameController.text,
      'lastNames': lastNameController.text,
      'identification': {
        'type': documentType ?? 'DNI',
        'number': documentController.text
      },
      'phoneNumber': phoneController.text,
      'email': emailController.text
    };

    print('📤 Actualizando datos del usuario: ${widget.userId}');
    print('📤 URL: $url');
    print('📤 Body: ${jsonEncode(body)}');

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Update initial values
        setState(() {
          initialName = nameController.text;
          initialLastName = lastNameController.text;
          initialDocument = documentController.text;
          initialEmail = emailController.text;
          initialPhone = phoneController.text;
        });
        print('✅ Información actualizada con éxito');
        return true;
      } else {
        print(
            '❌ Error al actualizar la información. Código: ${response.statusCode}');
        print('❌ Respuesta: ${response.body}');

        // Verificar si el error es por nombres de campos incorrectos
        if (response.statusCode == 400 && response.body.contains("user:")) {
          print(
              '⚠️ Parece que los nombres de campos son diferentes. Intentando con nombres alternativos...');

          // Intentar con nombres de campos alternativos
          final Map<String, dynamic> altBody = {
            'user': nameController.text,
            'lastName': lastNameController.text,
            'dni': documentController.text,
            'phone': phoneController.text,
            'email': emailController.text
          };

          print('📤 Segundo intento con nombres alternativos');
          print('📤 Body alternativo: ${jsonEncode(altBody)}');

          final altResponse = await http.patch(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(altBody),
          );

          print(
              '📥 Respuesta alternativa status code: ${altResponse.statusCode}');
          print('📥 Respuesta alternativa body: ${altResponse.body}');

          if (altResponse.statusCode == 200) {
            setState(() {
              initialName = nameController.text;
              initialLastName = lastNameController.text;
              initialDocument = documentController.text;
              initialEmail = emailController.text;
              initialPhone = phoneController.text;
            });
            print('✅ Información actualizada con éxito (nombres alternativos)');
            return true;
          } else {
            showSnackBar(
                'Error al actualizar la información: ${altResponse.statusCode} - ${altResponse.body}');
            return false;
          }
        } else {
          showSnackBar(
              'Error al actualizar la información: ${response.statusCode} - ${response.body}');
          return false;
        }
      }
    } catch (e) {
      print('❌ Error updating user info: $e');
      showSnackBar('Error de conexión: $e');
      return false;
    }
  }

  Future<void> saveChanges() async {
    if (!isEditing) return;

    setState(() {
      isSaving = true;
    });

    // First upload image if there's a new one
    bool imageUploaded = true;
    if (newProfileImage != null) {
      imageUploaded = await uploadProfileImage();
    }

    // Then update user info
    bool infoUpdated = true;
    if (imageUploaded) {
      infoUpdated = await updateUserInfo();
    }

    setState(() {
      isSaving = false;
      isEditing = false;
      showSuccessMessage = imageUploaded && infoUpdated;

      if (showSuccessMessage) {
        // Reset newProfileImage since it's now uploaded
        newProfileImage = null;

        // Actualizar los valores iniciales por si el usuario hace más cambios
        initialName = nameController.text;
        initialLastName = lastNameController.text;
        initialDocument = documentController.text;
        initialEmail = emailController.text;
        initialPhone = phoneController.text;
      }
    });

    if (showSuccessMessage) {
      // Mostrar el mensaje de éxito por 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showSuccessMessage = false;
          });
        }
      });

      // Si hubo cambios exitosos, actualizar la vista
      // con los datos más recientes del servidor
      await fetchUserData();
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            // Cuando el usuario presiona el botón de retroceso, regresamos
            // con un resultado booleano (true) si hubo cambios guardados
            Navigator.pop(context, showSuccessMessage);
          },
        ),
        titleSpacing: 0,
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      backgroundColor: Colors.white,
      // Añadir resizeToAvoidBottomInset: true para ajustar automáticamente el tamaño
      resizeToAvoidBottomInset: true,
      // Usar SingleChildScrollView para permitir que el contenido sea scrollable
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                // Añadimos padding adicional en la parte inferior para evitar que el contenido
                // quede debajo del teclado
                padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16.0),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: newProfileImage != null
                                ? FileImage(newProfileImage!) as ImageProvider
                                : (profileImageUrl != null
                                    ? NetworkImage(profileImageUrl!)
                                        as ImageProvider
                                    : null),
                            child: (newProfileImage == null &&
                                    profileImageUrl == null)
                                ? const Icon(Icons.person,
                                    size: 50, color: Colors.grey)
                                : null,
                          ),
                          GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFC20B0C),
                                    Color(0xFF7E0F9D),
                                    Color(0xFF2616C7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildTextField('Nombres', nameController),
                    buildTextField('Apellidos', lastNameController),
                    buildTextField('N° Documento', documentController),
                    buildTextField('Correo', emailController),
                    buildTextField('Celular', phoneController),
                    const SizedBox(height: 50), // Espacio para el botón
                    if (showSuccessMessage)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4EDDA),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Perfil actualizado con éxito',
                                style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton(
                        onPressed:
                            (isEditing && !isSaving) ? saveChanges : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (isEditing && !isSaving)
                              ? Colors.black
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
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
                            : const Text(
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
            ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        controller: controller,
        onChanged: (value) => checkForChanges(),
      ),
    );
  }
}
