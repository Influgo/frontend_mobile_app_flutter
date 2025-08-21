import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/events/data/models/event_model.dart';

class ApplicationPage extends StatelessWidget {
  final Event event;

  const ApplicationPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Espaciado superior
              const SizedBox(height: 238),
              
              // Ícono de éxito
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Color(0xFFDBF2DD),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/check.gif',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Título principal
              const Text(
                '¡Tu postulación fue enviada con éxito!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtítulo explicativo
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Si eres seleccionado, recibirás una notificación para firmar el contrato y confirmar tu participación en el evento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ),
              
              // Espaciador flexible para empujar el botón hacia abajo
              const Spacer(),
              
              // Botón "Ir a mis postulaciones"
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Aquí iría la navegación a la página de postulaciones
                      Navigator.pop(context);
                      /*
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Redirigiendo a mis postulaciones...'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                      */
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Ir a mis postulaciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
