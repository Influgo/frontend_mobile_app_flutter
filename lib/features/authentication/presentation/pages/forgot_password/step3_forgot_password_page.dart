import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/forgot_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/error_text_widget.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/password_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('new_password', _newPasswordController.text);
      print('Contraseña guardada exitosamente');
    } catch (e) {
      print('Error al guardar contraseña: $e');
      throw Exception('Error al guardar la contraseña');
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
        _savePassword().then((_) {
          if (mounted) ForgotPasswordPage.goToNextStep(context);
        });
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
                                  color: Colors.grey),
                            ),
                            SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8.0, right: 8.0, top: 8.0),
                                  child: Icon(Icons.circle, size: 8),
                                ),
                                Expanded(
                                  child: Text(
                                    'Entre 8 y 20 caracteres',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8.0, right: 8.0, top: 8.0),
                                  child: Icon(Icons.circle, size: 8),
                                ),
                                Expanded(
                                  child: Text(
                                    'Al menos 1 letra mayúscula y 1 letra minúscula',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8.0, right: 8.0, top: 8.0),
                                  child: Icon(Icons.circle, size: 8),
                                ),
                                Expanded(
                                  child: Text(
                                    '1 o más caracteres especiales',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey),
                                  ),
                                ),
                              ],
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
