import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/gradient_bars.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';

class Step4RegisterPage extends StatefulWidget {
  const Step4RegisterPage({super.key});

  @override
  State<Step4RegisterPage> createState() => _Step4RegisterPageState();
}

class _Step4RegisterPageState extends State<Step4RegisterPage> {
  void validateAndContinue() {
    RegisterPage.goToNextStep(context);
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
                GradientBars(barCount: 3),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Frente de tu DNI:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fotografía frontal del DNI (en desarrollo)',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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
                'Continuar',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}
