import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/success_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/form_button.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/password_field.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLengthValid = false;
  bool _hasUppercase = false;
  bool _hasSpecialChar = false;

  void _validatePassword(String password) {
    setState(() {
      _isLengthValid = password.length >= 8 && password.length <= 20;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _isButtonEnabled = _isLengthValid &&
          _hasUppercase &&
          _hasSpecialChar &&
          _newPasswordController.text == _confirmPasswordController.text;
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa tu nueva contraseña',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Por favor, introduce tu nueva contraseña, asegúrate que sea segura.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _newPasswordController,
              errorText: !_isLengthValid || !_hasUppercase || !_hasSpecialChar 
                  ? 'La contraseña no es válida'
                  : null,
              onChanged: (value) {
                _validatePassword(value);
              },
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirmPasswordController,
              errorText: _confirmPasswordController.text.isNotEmpty && 
                        _newPasswordController.text != _confirmPasswordController.text
                  ? 'Las contraseñas no coinciden'
                  : null,
              onChanged: (value) {
                _validatePassword(_newPasswordController.text);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Recuerda que tu contraseña debe incluir:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildValidationItem(
              'Entre 8 y 20 caracteres',
              _isLengthValid,
            ),
            _buildValidationItem(
              '1 letra mayúscula',
              _hasUppercase,
            ),
            _buildValidationItem(
              '1 o más caracteres especiales',
              _hasSpecialChar,
            ),
            const Spacer(),
            FormButton(
              text: 'Cambiar contraseña',
              isEnabled: _isButtonEnabled,
              onPressed: _isButtonEnabled
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SuccessPasswordPage(onPressed: () { 
                         },)),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.error,
          color: isValid ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isValid ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}