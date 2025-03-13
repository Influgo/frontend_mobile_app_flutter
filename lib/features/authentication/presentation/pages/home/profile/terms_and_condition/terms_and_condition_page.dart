import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text(
          'Términos y condiciones',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTermSection(
                title: '1. Aceptación de los Términos',
                content:
                    'Al registrarte en nuestro aplicativo, aceptas cumplir con estos términos y condiciones. Si no estás de acuerdo, no podrás usar nuestros servicios.',
              ),
              _buildTermSection(
                title: '2. Registro de Cuenta',
                content:
                    'Para acceder a nuestros servicios, deberás crear una cuenta proporcionando información veraz y actualizada. Eres responsable de mantener la confidencialidad de tus datos de acceso.',
              ),
              _buildTermSection(
                title: '3. Uso del Aplicativo',
                content:
                    'Nuestro aplicativo está diseñado para apoyar a emprendedores. Aceptas utilizarlo de manera legal y respetuosa, sin infringir los derechos de otros usuarios ni la ley.',
              ),
              _buildTermSection(
                title: '4. Protección de Datos',
                content:
                    'Nos comprometemos a proteger tu privacidad. Toda la información que proporciones será tratada de acuerdo con nuestra Política de Privacidad.',
              ),
              _buildTermSection(
                title: '5. Modificaciones a los Servicios',
                content:
                    'Podemos actualizar o modificar el aplicativo en cualquier momento. Te notificaremos de cambios significativos para que decidas si deseas continuar usando el servicio.',
              ),
              _buildTermSection(
                title: '6. Terminación del Servicio',
                content:
                    'Nos reservamos el derecho de suspender o finalizar el servicio en caso de incumplimiento de estos términos.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          SizedBox(height: 4),
          Text(content, style: TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }
}
