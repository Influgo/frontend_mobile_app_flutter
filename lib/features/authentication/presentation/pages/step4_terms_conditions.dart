import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Step4TermsConditionsPage extends StatelessWidget {
  const Step4TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Spacer(),
                SvgPicture.asset(
                  'assets/images/influyo_logo.svg',
                  height: 25,
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Términos y Condiciones',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _TermsSection(
                        number: '1',
                        title: 'Aceptación de los Términos',
                        description:
                            'Al registrarte en nuestro aplicativo, aceptas cumplir con estos términos y condiciones. Si no estás de acuerdo, no podrás usar nuestros servicios.',
                      ),
                      _TermsSection(
                        number: '2',
                        title: 'Registro de Cuenta',
                        description:
                            'Para acceder a nuestros servicios, deberás crear una cuenta proporcionando información veraz y actualizada. Eres responsable de mantener la confidencialidad de tus datos de acceso.',
                      ),
                      _TermsSection(
                        number: '3',
                        title: 'Uso del Aplicativo',
                        description:
                            'Nuestro aplicativo está diseñado para apoyar a emprendedores. Aceptas utilizarlo de manera legal y respetuosa, sin infringir los derechos de otros usuarios ni la ley.',
                      ),
                      _TermsSection(
                        number: '4',
                        title: 'Protección de Datos',
                        description:
                            'Nos comprometemos a proteger tu privacidad. Toda la información que proporciones será tratada de acuerdo con nuestra Política de Privacidad.',
                      ),
                      _TermsSection(
                        number: '5',
                        title: 'Modificaciones a los Servicios',
                        description:
                            'Podemos actualizar o modificar el aplicativo en cualquier momento. Te notificaremos de cambios significativos para que decidas si deseas continuar usando el servicio.',
                      ),
                      _TermsSection(
                        number: '6',
                        title: 'Terminación del Servicio',
                        description:
                            'Nos reservamos el derecho de suspender o cancelar tu cuenta si incumples estos términos o realizas actividades que consideremos inadecuadas.',
                      ),
                      _TermsSection(
                        number: '7',
                        title: 'Limitación de Responsabilidad',
                        description:
                            'No seremos responsables por pérdidas o daños derivados del uso del aplicativo, incluyendo pero no limitado a problemas técnicos o interrupciones en el servicio.',
                      ),
                      _TermsSection(
                        number: '8',
                        title: 'Contacto',
                        description:
                            'Si tienes alguna pregunta o inquietud sobre estos términos, contáctanos a través de [correo electrónico/contacto en la app].',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only( bottom: 0, left: 12, right: 12),
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
                  onPressed: () {
                    //nextito
                  },
                  child: const Text(
                    'Acepto y continuar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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

class _TermsSection extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _TermsSection({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. $title',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6A6A6A),
            ),
          ),
        ],
      ),
    );
  }
}
