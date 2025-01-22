import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/change_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/form_button.dart';

import '../../widgets/custom_input.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _FindAccountPageState();
}

class _FindAccountPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  bool _isButtonEnabled = false;

  void _validateInput(String value) {
    setState(() {
      _isButtonEnabled = value.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Encuentra tu cuenta',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Por favor, ingresa tu correo o celular para buscar tu cuenta',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            CustomInput(
              label: 'Correo o celular',
              controller: _emailOrPhoneController,
              onChanged: _validateInput,
            ),
            const Spacer(),
            FormButton(
              text: 'Siguiente',
              isEnabled: _isButtonEnabled,
              onPressed: _isButtonEnabled
                  ? () {
                      // Navega a la página de cambio de contraseña
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordPage(),
                        ),
                      );
                    }
                  : null,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
