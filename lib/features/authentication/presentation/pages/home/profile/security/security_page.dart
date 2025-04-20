import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/profile_page.dart';

import 'delete_account/delete_account_page.dart';
import 'delete_account/success_page.dart';

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
          buildSecurityOption(context, 'Eliminar cuenta', DeleteAccountPage()),
          buildSecurityOption(
              context, 'Cambiar contraseña', DeleteAccountSuccessPage()),
        ],
      ),
    );
  }

  Widget buildSecurityOption(BuildContext context, String title, Widget page) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.black),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
        ),
        if (title != 'Cambiar contraseña')
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(height: 1, thickness: 1),
          ),
      ],
    );
  }
}
