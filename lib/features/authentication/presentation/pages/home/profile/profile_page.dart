import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/home_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/edit_profile_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/entrepreneur/entrepreneur_profile_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/security/security_page.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white, 
      ));
    });
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
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
          ,
        ),
        titleSpacing: 0,
        title: Text(
          'Perfil',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 13),
            child: IconButton(
              icon:
                  Icon(Icons.notifications_none, color: Colors.black, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    // backgroundImage:
                    //     NetworkImage(''),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Eliza Maria Torres Vargas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Ver perfil',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios,
                        color: Colors.black, size: 16),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfilePage()),
                      );
                    },
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  buildSection(context, 'Configuración', [
                    'Perfil del emprendimiento',
                    'Métodos de pago',
                    'Historial de pagos',
                    'Seguridad',
                    'Faltas'
                  ]),
                  buildSection(context, 'Asistencia',
                      ['Centro de ayuda', 'Reportar un problema']),
                  buildSection(context, 'Legal', ['Término y condiciones']),
                  buildSection(context, 'Inicio de sesión', ['Cerrar sesión'],
                      isRed: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection(BuildContext context, String title, List<String> items,
      {bool isRed = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        Column(
          children: List.generate(items.length, (index) {
            return Column(
              children: [
                ListTile(
                  title: Text(
                    items[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.arrow_forward_ios,
                        color: Colors.black, size: 16),
                    onPressed: () {
                      navigateToPage(context, items[index]);
                    },
                  ),
                  onTap: () {
                    navigateToPage(context, items[index]);
                  },
                ),
                if (index < items.length - 1) Divider(height: 1, thickness: 1),
              ],
            );
          }),
        ),
      ],
    );
  }

  void navigateToPage(BuildContext context, String option) {
    final Map<String, Widget> routes = {
      'Perfil del emprendimiento': EntrepreneurProfilePage(),
      'Métodos de pago': EditProfilePage(),
      'Historial de pagos': EditProfilePage(),
      'Seguridad': SecurityPage(),
      'Faltas': EditProfilePage(),
      'Centro de ayuda': EditProfilePage(),
      'Reportar un problema': EditProfilePage(),
      'Término y condiciones': EditProfilePage(),
      'Cerrar sesión': EditProfilePage(),
    };

    if (routes.containsKey(option)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => routes[option]!),
      );
    } else {
      print("No hay una pantalla definida para '$option'");
    }
  }
}
