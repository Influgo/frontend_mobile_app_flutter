import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/login_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/hoverable_elevated_button.dart';

class SelectProfilePage extends StatelessWidget {
  final VoidCallback onNextStep;

  const SelectProfilePage({
    super.key,
    required this.onNextStep,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/influyo_logo.svg',
                  height: 25,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selecciona tu perfil',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Elige el perfil que mejor se adapte a ti',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),
                HoverableElevatedButton(
                  text: 'Influencer',
                  onPressed: () {
                    // seleccionó influencer
                  },
                ),
                const SizedBox(height: 16),
                HoverableElevatedButton(
                  text: 'Emprendedor',
                  onPressed: onNextStep,
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
                    text: '¿Ya tienes una cuenta? ',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 34, 34, 34),
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: 'Iniciar sesión',
                        style: const TextStyle(
                          color: Color(0xFF6A6A6A),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const LoginPage(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return child;
                                },
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