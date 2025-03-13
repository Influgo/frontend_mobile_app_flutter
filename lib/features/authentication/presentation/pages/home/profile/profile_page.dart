import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/home_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/edit_profile_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/entrepreneurship/entrepreneurship_profile_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/help_center/help_center_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/report_problem/report_problem_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/security/security_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/home/profile/terms_and_condition/terms_and_condition_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/login/login_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
      ));
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        titleSpacing: 0,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 13),
            child: IconButton(
              icon: const Icon(Icons.notifications_none,
                  color: Colors.black, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  // backgroundImage: NetworkImage(''),
                ),
                const SizedBox(width: 12),
                const Expanded(
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
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: Colors.black, size: 16),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfilePage()),
                    );
                  },
                ),
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
                buildSection(context, 'Inicio de sesión', ['Cerrar sesión']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSection(BuildContext context, String title, List<String> items,
      {bool isRed = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
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
                      color: isRed ? Colors.red : Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.black, size: 16),
                  onTap: () {
                    if (items[index] == 'Cerrar sesión') {
                      _showLogoutDialog(context);
                    } else {
                      navigateToPage(context, items[index]);
                    }
                  },
                ),
                if (index < items.length - 1) const Divider(height: 1, thickness: 1),
              ],
            );
          }),
        ),
      ],
    );
  }

  void navigateToPage(BuildContext context, String option) {
    final Map<String, Widget> routes = {
      'Perfil del emprendimiento': const EntrepreneurshipProfilePage(),
      'Métodos de pago': const EditProfilePage(),
      'Historial de pagos': const EditProfilePage(),
      'Seguridad': const SecurityPage(),
      'Faltas': const EditProfilePage(),
      'Centro de ayuda': const HelpCenterPage(),
      'Reportar un problema': const ReportProblemPage(),
      'Término y condiciones': const TermsAndConditionsPage(),
    };

    if (routes.containsKey(option)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => routes[option]!),
      );
    } else {
      debugPrint("No hay una pantalla definida para '$option'");
    }
  }



  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Fondo borroso
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              // Nivel de desenfoque
              child: Container(
                color: Colors.black.withOpacity(0.3), // Oscurecer el fondo
              ),
            ),
            Center(
              child: AlertDialog(
                backgroundColor: Colors.white,
                // Color de fondo del pop-up
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.amber, size: 40),
                    const SizedBox(height: 10),
                    const Text(
                      '¿Seguro que deseas cerrar sesión?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black
                      ),
                    ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),

                    ),
                    child: const Text(
                      'No, regresar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Sí, cerrar',
                      style: TextStyle(
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
