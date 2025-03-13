import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/step3_forgot_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/edit_profile_page.dart'; 
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/profile_page.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        titleSpacing: 0,
        title: Text(
          'Seguridad',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      body: ListView(
        children: [
          buildSecurityOption(context, 'Eliminar cuenta', EditProfilePage()), 
          buildSecurityOption(context, 'Cambiar contraseña', Step3ForgotPasswordPage()), 
        ],
      ),
    );
  }

  Widget buildSecurityOption(BuildContext context, String title, Widget page) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page), 
            );
          },
        ),
        if (title != 'Cambiar contraseña') 
          Divider(height: 1, thickness: 1),
      ],
    );
  }
}
