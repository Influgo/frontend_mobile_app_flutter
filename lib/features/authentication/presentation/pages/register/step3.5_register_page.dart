import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';

class Step3_5RegisterPage extends StatefulWidget {
  const Step3_5RegisterPage({super.key});

  @override
  State<Step3_5RegisterPage> createState() => _Step3_5RegisterPageState();
}

class _Step3_5RegisterPageState extends State<Step3_5RegisterPage> {
  void validateAndContinue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('acceptTermsAndConditions', true);
    Navigator.of(context).pop(true);
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: goBack,
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: const InfluyoLogo(),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Tratamiento de datos personales',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Usted autoriza a Influyo a recopilar y almacenar la información consignada en su documento de identidad, incluyendo su imagen, con la única finalidad de verificar su identidad en este proceso.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'La información que Influyo pueda recopilar en este proceso será utilizada únicamente para efectos de comunicarse con usted en relación al proceso iniciado por este medio. En ningún caso, Influyo en mérito de esta cláusula le ofrecerá productos o servicios de Influyo.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Mantendremos su información hasta diez años después de que finalice su relación contractual con Influyo y no transferiremos su información a terceros no autorizados. En caso usted quiera ejercer sus derechos de acceso, rectificación, cancelación, oposición y revocación.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF222222),
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: validateAndContinue,
                          child: const Text(
                            'Acepto y continuar',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}