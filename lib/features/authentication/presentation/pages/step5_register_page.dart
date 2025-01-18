import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/gradient_bars.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';

class Step5RegisterPage extends StatefulWidget {
  const Step5RegisterPage({super.key});

  @override
  State<Step5RegisterPage> createState() => _Step5RegisterPageState();
}

class _Step5RegisterPageState extends State<Step5RegisterPage> {
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
                          'Foto de registro',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500),
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
                          'Antes de continuar, sigue estas instrucciones para validar tu identidad:',
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
                                'Asegúrate de estar en un lugar bien iluminado.',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
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
                                'Mantén tu rostro despejado.',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
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
                                'Coloca el móvil a la altura de tu rostro.',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
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
