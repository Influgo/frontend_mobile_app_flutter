import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/forgot_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_checkmark.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';

class Step4ForgotPasswordPage extends StatefulWidget {
  const Step4ForgotPasswordPage({super.key});

  @override
  State<Step4ForgotPasswordPage> createState() =>
      _Step4ForgotPasswordPageState();
}

class _Step4ForgotPasswordPageState extends State<Step4ForgotPasswordPage> {
  void validateAndContinue() {
    ForgotPasswordPage.goToNextStep(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          const Padding(
            padding: EdgeInsets.only(top: 30, left: 16, right: 16),
            child: InfluyoLogo(),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CustomCheckmarkSimple(),
                const SizedBox(height: 32),
                const Text(
                  'Tu contraseña se ha guardado con éxito',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    'Ahora podrás ingresar a tu cuenta con tu nueva contraseña',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey),
                    textAlign: TextAlign.center,
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
                    borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: validateAndContinue,
              child: const Text(
                'Siguiente',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ]));
  }
}
