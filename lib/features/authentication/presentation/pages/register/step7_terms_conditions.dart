import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Step7TermsConditionsPage extends StatefulWidget {
  final Map<String, dynamic> requestBody;

  const Step7TermsConditionsPage({super.key, required this.requestBody});

  @override
  _Step7TermsConditionsPageState createState() =>
      _Step7TermsConditionsPageState();
}

class _Step7TermsConditionsPageState extends State<Step7TermsConditionsPage> {
  final Logger logger = Logger();
  final AuthRemoteDataSource authRemoteDataSource = AuthRemoteDataSourceImpl(client: http.Client());

  Future<void> validateAndContinue() async {
    final requestBody = widget.requestBody;

    if (!requestBody.containsKey("entrepreneurshipName")) {
      String alias = '';
      for (var social in requestBody['socials']) {
        if (social['name'] == 'Instagram' || social['name'] == 'Youtube') {
          alias = social['socialUrl'].split('/').last;
          break;
        }
      }
      requestBody['alias'] = alias;
    }

    logger.i('Request Body in Step7: $requestBody');

    try {
      http.Response response;
      if (requestBody.containsKey("entrepreneurshipName")) {
        response = await authRemoteDataSource.registerEntrepreneur(requestBody);
      } else {
        response = await authRemoteDataSource.registerInfluencer(requestBody);
      }

      if (response.statusCode == 200) {
        logger.i('Registro exitoso: ${response.body}');
        if (mounted) {
          _showSnackBar("Usuario registrado con éxito");
          RegisterPage.goToNextStep(context);
        }
      } else {
        logger.e('Error en el registro: ${response.body}');
        _showSnackBar("Error en el registro: ${response.body}");
      }
    } catch (e) {
      logger.e('Error en el registro: $e');
      _showSnackBar("Error en el registro: $e");
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InfluyoLogo(),
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
              padding: const EdgeInsets.only(bottom: 0, left: 12, right: 12),
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