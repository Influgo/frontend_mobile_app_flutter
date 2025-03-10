import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/profile_page.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isEditing = false;
  bool showSuccessMessage = false;

  @override
  void initState() {
    super.initState();

  }


  // void fetchUserData() async {
 
  //   // final userData = await userRepository.getUserProfile();
  //   // setState(() {
  //   //   nameController.text = userData.name;
  //   //   dniController.text = userData.dni;
  //   //   emailController.text = userData.email;
  //   //   phoneController.text = userData.phone;
  //   // });
  // }

  void checkForChanges() {
    setState(() {

      isEditing = nameController.text.isNotEmpty ||
          dniController.text.isNotEmpty ||
          emailController.text.isNotEmpty ||
          phoneController.text.isNotEmpty;
    });
  }

  void saveChanges() {

    // userRepository.updateProfile(
    //   name: nameController.text,
    //   dni: dniController.text,
    //   email: emailController.text,
    //   phone: phoneController.text,
    // );
    
    setState(() {
      isEditing = false;
      showSuccessMessage = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        showSuccessMessage = false;
      });
    });
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        titleSpacing: 0,
        title: Text(
          'Perfil',
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
                          Color(0xFFC20B0C), // Rojo oscuro
                          Color(0xFF7E0F9D), // Morado
                          Color(0xFF2616C7), // Azul
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
                onPressed: isEditing ? saveChanges : null,
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