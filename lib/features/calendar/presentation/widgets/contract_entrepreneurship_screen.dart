import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/data/models/extended_event_model.dart';
import 'package:frontend_mobile_app_flutter/features/calendar/presentation/widgets/signed_contract_screen.dart';

class ContractEntrepreneurshipScreen extends StatefulWidget {
  final EventApplication application;
  final String eventName;

  const ContractEntrepreneurshipScreen({
    super.key,
    required this.application,
    required this.eventName,
  });

  @override
  State<ContractEntrepreneurshipScreen> createState() => _ContractEntrepreneurshipScreenState();
}

class _ContractEntrepreneurshipScreenState extends State<ContractEntrepreneurshipScreen> {
  bool _isScrolledToBottom = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() {
        _isScrolledToBottom = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: Text(
          'Contrato de Emprendedor',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Contenido del contrato
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContractSection(
                    '1. Aceptación de los Términos',
                    'Al registrarte en nuestro aplicativo, aceptas cumplir con estos términos y condiciones. Si no estás de acuerdo, no podrás usar nuestros servicios.',
                  ),
                  
                  _buildContractSection(
                    '2. Registro de Cuenta',
                    'Para acceder a nuestros servicios, deberás crear una cuenta proporcionando información veraz y actualizada. Eres responsable de mantener la confidencialidad de tus datos de acceso.',
                  ),

                  _buildContractSection(
                    '3. Uso del Aplicativo',
                    'Nuestro aplicativo está diseñado para apoyar a emprendedores. Aceptas utilizarlo de manera legal y respetuosa, sin infringir los derechos de otros usuarios ni la ley.',
                  ),

                  _buildContractSection(
                    '4. Protección de Datos',
                    'Nos comprometemos a proteger tu privacidad. Toda la información que proporciones será tratada de acuerdo con nuestra Política de Privacidad.',
                  ),

                  _buildContractSection(
                    '5. Modificaciones a los Servicios',
                    'Podemos actualizar o modificar el aplicativo en cualquier momento. Te notificaremos de cambios significativos para que decidas si deseas continuar usando el servicio.',
                  ),

                  _buildContractSection(
                    '6. Terminación del Servicio',
                    'Nos reservamos el derecho de suspender o cancelar tu cuenta si incumples estos términos o realizas actividades que consideremos inadecuadas.',
                  ),

                  _buildContractSection(
                    '7. Limitación de Responsabilidad',
                    'No seremos responsables por pérdidas o daños derivados del uso del aplicativo, incluyendo pero no limitado a problemas técnicos o interrupciones en el servicio.',
                  ),

                  _buildContractSection(
                    '8. Contacto',
                    'Si tienes alguna pregunta o inquietud sobre estos términos, contáctanos a través de [correo electrónico/contacto en la app].',
                  ),

                  /*
                  SizedBox(height: 30),
                  
                  Text(
                    'Al firmar este documento, ambas partes declaran haber leído, entendido y aceptado todos los términos y condiciones establecidos en el presente contrato.',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  */
                  //SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Botones de acción
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                /*
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                */
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isScrolledToBottom ? _navigateToSignedContract : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isScrolledToBottom ? Colors.black : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(100, 60),
                      elevation: 0,
                    ),
                    child: Text(
                      _isScrolledToBottom ? 'Firmar y enviar contrato' : 'Lee todo el contrato',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void _navigateToSignedContract() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignedContractScreen(),
      ),
    );

    // Si se completó el proceso, volver con resultado exitoso
    if (result == true) {
      Navigator.pop(context, true);
    }
  }
}
