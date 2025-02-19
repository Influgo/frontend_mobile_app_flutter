import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/core/constants/api_endpoints.dart';
import 'package:frontend_mobile_app_flutter/core/utils/api_helper.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/forgot_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/error_text_widget.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/password_field.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/password_requirement_row.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Step3ForgotPasswordPage extends StatefulWidget {
  const Step3ForgotPasswordPage({super.key});

  @override
  State<Step3ForgotPasswordPage> createState() =>
      _Step3ForgotPasswordPageState();
}

class _Step3ForgotPasswordPageState extends State<Step3ForgotPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _newPasswordError;
  String? _confirmPasswordError;

  bool _hasMinLength = false;
  bool _hasUpperLower = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePasswordRules);
  }

  void _validatePasswordRules() {
    String password = _newPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 8 && password.length <= 20;
      _hasUpperLower = RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(password);
      _hasSpecialChar =
          RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password);
    });
  }

  Future<void> _resetPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdentifier = prefs.getString('email_forgot_password');
      final token = prefs.getString('verification_code_forgot_password');
      final password = _newPasswordController.text;

      if (userIdentifier == null || token == null) {
        throw Exception(
            'No se encontraron datos necesarios en SharedPreferences');
      }

      final response = await http.post(
        Uri.parse(APIHelper.buildUrl(resetPasswordEndpoint).toString()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userIdentifier": userIdentifier,
          "password": password,
          "token": token
        }),
      );

      if (response.statusCode == 200) {
        print('Contraseña cambiada exitosamente');
        if (mounted) ForgotPasswordPage.goToNextStep(context);
      } else {
        print('Error al cambiar contraseña: ${response.body}');
        throw Exception('Error al cambiar la contraseña');
      }
    } catch (e) {
      print('Error en la solicitud: $e');
    }
  }

  void _validateAndChangePassword() async {
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;

      String newPassword = _newPasswordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();

      if (newPassword.isEmpty) {
        _newPasswordError = 'Contraseña es requerida';
      } else if (newPassword.length < 8 || newPassword.length > 20) {
        _newPasswordError = 'Contraseña debe tener entre 8 y 20 caracteres';
      } else if (!RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(newPassword)) {
        _newPasswordError = 'Debe contener mayúsculas y minúsculas';
      } else if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])')
          .hasMatch(newPassword)) {
        _newPasswordError = 'Debe incluir un carácter especial';
      }

      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Confirma tu contraseña';
      } else if (confirmPassword != newPassword) {
        _confirmPasswordError = 'Las contraseñas no coinciden';
      }

      if (_newPasswordError == null && _confirmPasswordError == null) {
        _resetPassword();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
            child: Column(
              children: [
                const InfluyoLogo(),
                const Padding(
                  padding: EdgeInsets.only(top: 30, left: 16, right: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ingresa contraseña',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Por favor, introduce tu nueva contraseña',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      PasswordField(
                        controller: _newPasswordController,
                        label: "Contraseña",
                      ),
                      if (_newPasswordError != null)
                        ErrorTextWidget(error: _newPasswordError!),
                      const SizedBox(height: 16),
                      PasswordField(
                        controller: _confirmPasswordController,
                        label: "Confirmar contraseña",
                      ),
                      if (_confirmPasswordError != null)
                        ErrorTextWidget(error: _confirmPasswordError!),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recuerda que tu contraseña debe incluir:',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600]),
                            ),
                            SizedBox(height: 16),
                            PasswordRequirementRow(
                              text: 'Entre 8 y 20 caracteres',
                              isValid: _hasMinLength,
                            ),
                            SizedBox(height: 8),
                            PasswordRequirementRow(
                              text:
                                  'Al menos 1 letra mayúscula y 1 letra minúscula',
                              isValid: _hasUpperLower,
                            ),
                            SizedBox(height: 8),
                            PasswordRequirementRow(
                              text: '1 o más caracteres especiales',
                              isValid: _hasSpecialChar,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 30,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF222222),
                padding: const EdgeInsets.symmetric(vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: _validateAndChangePassword,
              child: const Text(
                'Cambiar contraseña',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}
