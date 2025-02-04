import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step3.5_register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/gradient_bars.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Step3RegisterPage extends StatefulWidget {
  const Step3RegisterPage({super.key});

  @override
  State<Step3RegisterPage> createState() => _Step3RegisterPageState();
}

class _Step3RegisterPageState extends State<Step3RegisterPage> {
  bool _acceptTermsAndConditions = false;

  @override
  void initState() {
    super.initState();
    _loadCheckboxState();
  }

  Future<void> _loadCheckboxState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _acceptTermsAndConditions =
          prefs.getBool('acceptTermsAndConditions') ?? false;
    });
  }

  Future<void> _saveCheckboxState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('acceptTermsAndConditions', value);
  }

  void validateAndContinue() {
    if (_acceptTermsAndConditions) {
      RegisterPage.goToNextStep(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes aceptar el Tratamiento de datos personales.')),
      );
    }
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
                          'Vamos a validar tu identidad',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Saca una foto a tu DNI',
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
                                'Enfoca bien tu documento de identidad.',
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
              ],
            ),
          ),
          Positioned(
            bottom: 125,
            left: 30,
            right: 30,
            child: Row(
              children: [
                Checkbox(
                  value: _acceptTermsAndConditions,
                  onChanged: (bool? value) {
                    setState(() {
                      _acceptTermsAndConditions = value ?? false;
                      _saveCheckboxState(_acceptTermsAndConditions);
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Step3_5RegisterPage(),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          _acceptTermsAndConditions = true;
                        });
                      }
                    },
                    child: RichText(
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'He leído y acepto el ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Tratamiento de datos personales',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    Color(0xFFC20B0C),
                                    Color(0xFF7E0F9D),
                                    Color(0xFF2616C7)
                                  ],
                                ).createShader(
                                    const Rect.fromLTWH(0, 0, 200, 20)),
                            ),
                          ),
                        ],
                      ),
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
          ),
        ],
      ),
    );
  }
}
