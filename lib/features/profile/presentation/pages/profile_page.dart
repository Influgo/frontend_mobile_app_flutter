import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_mobile_app_flutter/features/shared/presentation/pages/home_page.dart';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/entrepreneurship/entrepreneurship_profile_page.dart';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/influencer/influencer_profile_page.dart';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/influencer/my_applications_page.dart';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/help_center/help_center_page.dart';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/report_problem/report_problem_page.dart';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/security/security_page.dart';
import 'package:frontend_mobile_app_flutter/features/profile/presentation/pages/terms_and_condition/terms_and_condition_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/login/login_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/modals/account_under_review_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = '';
  String? profileImageUrl;
  String userId = '';
  bool isLoading = true;
  String? userRole;
  String? accountStatus;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');
      final token = prefs.getString('token');
      final storedUserRole = prefs.getString('userRole');

      if (storedUserId == null || token == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      userId = storedUserId;
      userRole = storedUserRole; // Cargar rol almacenado

      await _fetchUserData(token);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error al cargar perfil: $e');
    }
  }

  Future<void> _fetchUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://influyo-testing.ryzeon.me/api/v1/account/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          fullName = '${data['userDto']['names']} ${data['userDto']['lastNames']}';
          
          // Obtener el estado de la cuenta
          accountStatus = data['userDto']?['accountStatus'];

          if (data['userDto']['profileImage'] != null &&
              data['userDto']['profileImage']['url'] != null) {
            profileImageUrl = data['userDto']['profileImage']['url'];
          }

          // Extraer el rol del usuario si no estaba almacenado localmente
          if (userRole == null && data['userDto'] != null && data['userDto']['roles'] != null && data['userDto']['roles'].isNotEmpty) {
            final roles = data['userDto']['roles'] as List;
            if (roles.isNotEmpty && roles[0]['role'] != null) {
              userRole = roles[0]['role']['name'];
              // Almacenar el rol para futuros usos
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString('userRole', userRole!);
              });
            }
          }

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        debugPrint('Error al cargar perfil: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error al cargar perfil: $e');
    }
  }

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
            padding: const EdgeInsets.only(right: 20),
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
                isLoading
                    ? const CircularProgressIndicator()
                    : profileImageUrl != null
                        ? CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade200,
                            child: ClipOval(
                              child: Image.network(
                                profileImageUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person,
                                      size: 30, color: Colors.grey);
                                },
                              ),
                            ),
                          )
                        : const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person,
                                size: 30, color: Colors.white),
                          ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isLoading
                          ? const SizedBox(
                              width: 100,
                              height: 16,
                              child: LinearProgressIndicator(),
                            )
                          : Text(
                              fullName.isNotEmpty ? fullName : 'Usuario',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                      const Text(
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
                  onPressed: () async {
                    // Navegar a EditProfilePage y esperar el resultado
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditProfilePage(userId: userId)),
                    );

                    // Si hay cambios guardados (result == true), recargar el perfil
                    if (result == true) {
                      setState(() {
                        isLoading = true;
                      });

                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('token');

                      if (token != null) {
                        await _fetchUserData(token);
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                buildSection(context, 'Configuración', _getConfigurationItems()),
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
                    } else if (items[index] == 'Métodos de pago' && userRole?.toUpperCase() == 'INFLUENCER') {
                      _showAccountUnderReviewModal();
                    } else if (accountStatus?.toUpperCase() == 'PENDING_VERIFICATION' &&
                               (items[index] == 'Mis postulaciones' ||
                                items[index] == 'Historial de pagos' ||
                                items[index] == 'Faltas')) {
                      _showAccountUnderReviewModal();
                    } else {
                      navigateToPage(context, items[index]);
                    }
                  },
                ),
                if (index < items.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, thickness: 1),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  List<String> _getConfigurationItems() {
    if (userRole?.toUpperCase() == 'INFLUENCER') {
      return [
        'Perfil del Influencer',
        'Mis postulaciones',
        'Métodos de pago',
        'Historial de pagos',
        'Seguridad',
        'Faltas'
      ];
    } else {
      // Por defecto mostrar opciones de emprendedor
      return [
        'Perfil del emprendimiento',
        'Métodos de pago',
        'Historial de pagos',
        'Seguridad',
        'Faltas'
      ];
    }
  }

  void navigateToPage(BuildContext context, String option) {
    final Map<String, Widget> routes = {
      'Perfil del emprendimiento': const EntrepreneurshipProfilePage(),
      'Perfil del Influencer': const InfluencerProfilePage(),
      'Mis postulaciones': const MyApplicationsPage(),
      'Métodos de pago': const EntrepreneurshipProfilePage(),
      'Historial de pagos': const EntrepreneurshipProfilePage(),
      'Seguridad': const SecurityPage(),
      'Faltas': const EntrepreneurshipProfilePage(),
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
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            Center(
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(242, 201, 76, 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '¿Seguro que deseas cerrar sesión?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 58),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'No, regresar',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 58),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            'Sí, cerrar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAccountUnderReviewModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AccountUnderReviewModal(
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
