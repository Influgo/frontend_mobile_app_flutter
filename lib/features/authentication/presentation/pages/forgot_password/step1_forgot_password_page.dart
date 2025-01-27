import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/core/di/injection_container.dart';
import 'package:frontend_mobile_app_flutter/core/errors/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_email_field.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/error_text_widget.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/domain/usecases/forgot_password_usecase.dart';

class Step1ForgotPasswordPage extends StatefulWidget {
  final VoidCallback onNextStep;
  const Step1ForgotPasswordPage({
    super.key,
    required this.onNextStep,
  });

  @override
  State<Step1ForgotPasswordPage> createState() =>
      _Step1ForgotPasswordPageState();
}

class _Step1ForgotPasswordPageState extends State<Step1ForgotPasswordPage> {
  late final ForgotPasswordUseCase forgotPasswordUseCase;
  final TextEditingController emailController = TextEditingController();
  String? emailError;
  bool isLoading = false;

  Future<void> _saveEmailLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email_forgot_password', emailController.text.trim());
  }

  void validateAndContinue() async {
    FocusScope.of(context).unfocus();

    setState(() {
      emailError = emailController.text.trim().isEmpty
          ? 'Correo es requerido'
          : (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(emailController.text.trim())
              ? 'Correo no es válido'
              : null);
    });

    if (emailError != null) return;

    setState(() => isLoading = true);

    try {
      // Comentar la sgte linea para hacer pruebas sin conexion
      await forgotPasswordUseCase.execute(emailController.text.trim());
      await _saveEmailLocally();
      if (mounted) widget.onNextStep();
    } on ServerException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    forgotPasswordUseCase = getIt<ForgotPasswordUseCase>();
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
                      'Encuentra tu cuenta',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Por favor, ingresa tu correo para buscar tu cuenta',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      children: [
                        CustomEmailField(
                          label: 'Correo',
                          controller: emailController,
                          maxLength: 100,
                        ),
                        if (emailError != null)
                          ErrorTextWidget(error: emailError!),
                        const SizedBox(height: 16),
                      ],
                    ),
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
                backgroundColor:
                    isLoading ? Colors.grey : const Color(0xFF222222),
                padding: const EdgeInsets.symmetric(vertical: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: isLoading ? null : validateAndContinue,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Siguiente',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          )
        ],
      ),
    );
  }
}
