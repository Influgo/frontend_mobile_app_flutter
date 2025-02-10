import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_email_or_number_field.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/forgot_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_name_field.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/password_field.dart';
import 'package:flutter/gestures.dart';

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

    final url = Uri.parse(
        'https://influyo-testing.ryzeon.me/api/v1/authentication/login');

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
        _showSnackBar("Credenciales correctas, bienvenido a influyo!");
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

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
        child: Column(
          children: [
            const InfluyoLogo(),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ingresa tus datos para acceder a tu cuenta',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),
                CustomEmailOrNumberField(
                    label: 'Correo, número o teléfono',
                    controller: _identifierController,
                    maxLength: 100),
                const SizedBox(height: 16),
                PasswordField(
                    controller: _passwordController, label: "Contraseña"),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      foregroundColor:
                          WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.hovered)) {
                          return const Color.fromARGB(255, 0, 107, 214);
                        }
                        return const Color.fromARGB(255, 0, 107, 214);
                      }),
                      animationDuration: const Duration(milliseconds: 100),
                    ),
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Color.fromARGB(255, 0, 107, 214),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _validateAndLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      backgroundColor: const Color.fromARGB(255, 34, 34, 34),
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
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Ingresar como invitado',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 34, 34, 34),
                      decoration: TextDecoration.underline,
                      decorationColor: const Color.fromARGB(255, 34, 34, 34),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Align(
                alignment: Alignment.center,
                child: Text.rich(
                  TextSpan(
                    text: '¿No tienes una cuenta? ',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 34, 34, 34), fontSize: 14),
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
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        const RegisterPage(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
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
