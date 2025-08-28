import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/core/constants/api_endpoints.dart';
import 'package:frontend_mobile_app_flutter/core/utils/api_helper.dart';
import 'package:frontend_mobile_app_flutter/features/shared/presentation/pages/home_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_email_or_number_field.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/forgot_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/password_field.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger logger = Logger();

  Future<void> _validateAndLogin() async {
    final String userIdentifier = _identifierController.text.trim();
    final String password = _passwordController.text.trim();

    if (userIdentifier.isEmpty || password.isEmpty) {
      _showSnackBar("Por favor, ingrese todos los campos");
      return;
    }

    final Map<String, dynamic> requestBody = {
      "userIdentifier": userIdentifier,
      "password": password,
    };

    final url = Uri.parse(APIHelper.buildUrl(loginEndpoint).toString());

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      logger.i('Request Body: $requestBody');
      logger.i('Response Status: ${response.statusCode}');
      logger.i('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String token = responseData['token'] ?? '';
        String userIdentifier = responseData['userIdentifier'] ?? '';
        String userId = responseData['userId']?.toString() ?? '';

        if (token.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          logger.i('Token almacenado exitosamente');
          await prefs.setString('userIdentifier', userIdentifier);
          logger.i('userIdentifier almacenado exitosamente');
          await prefs.setString('userId', userId);
          logger.i('userId almacenado exitosamente');

          bool roleObtained = await _fetchAndStoreUserRole(token, userIdentifier, userId, prefs, logger);

          logger.i('Token: $token');
          logger.i('userIdentifier: $userIdentifier');
          logger.i('userId: $userId');

          if (roleObtained) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            await _clearStoredData(prefs);
            _showSnackBar("Error al obtener información del usuario. Intente nuevamente.");
          }
        } else {
          _showSnackBar("Error al obtener el token");
        }
      } else if (response.statusCode == 400) {
        _showSnackBar("Credenciales incorrectas");
      } else {
        _showSnackBar("Error en el servidor, por favor intente nuevamente");
      }
    } catch (e) {
      logger.e('Error en la conexión: $e');
      _showSnackBar("Error en la conexión, por favor intente nuevamente");
    }
  }

  Future<bool> _fetchAndStoreUserRole(String token, String userIdentifier, String userId, SharedPreferences prefs, Logger logger) async {
    try {
      final identifier = userIdentifier.isNotEmpty ? userIdentifier : userId;

      final endpoint = 'https://influyo-testing.ryzeon.me/api/v1/account/$identifier';
      logger.i('Llamando al endpoint: $endpoint');
      
      final accountResponse = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (accountResponse.statusCode == 200) {
        final Map<String, dynamic> accountData = json.decode(accountResponse.body);
        logger.i('Respuesta del endpoint account: $accountData');

        String userRole = '';
        
        // Imprimir toda la respuesta para debuggear
        logger.i('Estructura completa de accountData: $accountData');
        
        // La respuesta viene anidada en 'userDto'
        if (accountData['userDto'] != null) {
          final userDto = accountData['userDto'];
          logger.i('userDto encontrado: $userDto');
          
          if (userDto['roles'] != null && userDto['roles'].isNotEmpty) {
            final roles = userDto['roles'] as List;
            logger.i('Roles encontrados: $roles');
            
            if (roles.isNotEmpty) {
              final firstRole = roles[0];
              logger.i('Primer rol: $firstRole');
              
              if (firstRole['name'] != null) {
                userRole = firstRole['name'].toString();
                logger.i('Rol extraído: $userRole');
              } else {
                logger.w('Estructura de rol incorrecta. firstRole[name]: ${firstRole['name']}');
              }
            }
          } else {
            logger.w('userDto[roles] es null o vacío: ${userDto['roles']}');
          }
        } else {
          logger.w('userDto es null en la respuesta');
        }

        if (userRole.isNotEmpty) {
          await prefs.setString('userRole', userRole);
          logger.i('userRole almacenado exitosamente: $userRole');
          return true;
        } else {
          logger.e('Rol de usuario vacío o no encontrado');
          return false;
        }
      } else {
        logger.w('Error al obtener información del usuario: ${accountResponse.statusCode}');
        return false;
      }
    } catch (e) {
      logger.e('Error al obtener el rol del usuario: $e');
      return false;
    }
  }

  Future<void> _clearStoredData(SharedPreferences prefs) async {
    await prefs.remove('token');
    await prefs.remove('userIdentifier');
    await prefs.remove('userId');
    await prefs.remove('userRole');
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // <- Esto es importante
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InfluyoLogo(),
                      const SizedBox(height: 20),
                      const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ingresa tus datos para acceder a tu cuenta',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      CustomEmailOrNumberField(
                        label: 'Correo, número o teléfono',
                        controller: _identifierController,
                        maxLength: 100,
                      ),
                      const SizedBox(height: 16),
                      PasswordField(
                        controller: _passwordController,
                        label: "Contraseña",
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text('¿Olvidaste tu contraseña?'),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _validateAndLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            backgroundColor:
                            const Color.fromARGB(255, 34, 34, 34),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Iniciar sesión',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Align(
                alignment: Alignment.center,
                child: Text.rich(
                  TextSpan(
                    text: '¿No tienes una cuenta? ',
                    style: const TextStyle(fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Regístrate',
                        style: const TextStyle(
                          color: Color(0xFF6A6A6A),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder: (context, _, __) =>
                                const RegisterPage(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
