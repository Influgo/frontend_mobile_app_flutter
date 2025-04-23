import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({super.key, required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? initialName, initialLastName, initialDni, initialEmail, initialPhone;
  bool isEditing = false;
  bool showSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final String url =
        'https://influyo-testing.ryzeon.me/api/v1/account/${widget.userId}';

    try {
      final response = await http.patch(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          initialName = nameController.text = data['user'] ?? '';
          initialLastName = lastNameController.text = data['lastName'] ?? '';
          initialDni = dniController.text = data['dni'] ?? '';
          initialEmail = emailController.text = data['email'] ?? '';
          initialPhone = phoneController.text = data['phone'] ?? '';
        });
      } else {
        showSnackBar('Error al obtener los datos');
      }
    } catch (e) {
      print('Error: $e');
      showSnackBar('Error de conexión');
    }

  }

  void checkForChanges() {
    setState(() {
      isEditing = nameController.text != initialName ||
          lastNameController.text != initialLastName ||
          dniController.text != initialDni ||
          emailController.text != initialEmail ||
          phoneController.text != initialPhone;
    });
  }

  Future<void> updateProfile() async {
    final String url =
        'https://influyo-testing.ryzeon.me/api/v1/account/${widget.userId}';

    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, String> body = {
      'user': nameController.text,
      'lastName': lastNameController.text,
      'dni': dniController.text,
      'phone': phoneController.text,
      'email': emailController.text,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          initialName = nameController.text;
          initialLastName = lastNameController.text;
          initialDni = dniController.text;
          initialEmail = emailController.text;
          initialPhone = phoneController.text;
          isEditing = false;
          showSuccessMessage = true;
        });

        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            showSuccessMessage = false;
          });
        });
      } else {
        showSnackBar('Error al actualizar el perfil');
      }
    } catch (e) {
      showSnackBar('No se pudo conectar con el servidor');
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text(
          'Editar Perfil',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330'),
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFC20B0C),
                          Color(0xFF7E0F9D),
                          Color(0xFF2616C7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            buildTextField('Nombre completo', nameController),
            buildTextField('Apellido', lastNameController),
            buildTextField('DNI', dniController),
            buildTextField('Correo', emailController),
            buildTextField('Celular', phoneController),
            Spacer(),
            if (showSuccessMessage)
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFD4EDDA),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
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
              margin: EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: isEditing ? updateProfile : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? Colors.black : Colors.grey,
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
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
          TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        controller: controller,
        onChanged: (value) => checkForChanges(),
      ),
    );
  }
}
