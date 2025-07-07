import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/data/models/validation_data.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';

class Step65ImagesNotValidatedPage extends StatefulWidget {
  final ValidationData validationData;
  final String errorMessage;

  const Step65ImagesNotValidatedPage({
    super.key,
    required this.validationData,
    required this.errorMessage,
  });

  @override
  State<Step65ImagesNotValidatedPage> createState() =>
      _Step65ImagesNotValidatedPageState();
}

class _Step65ImagesNotValidatedPageState
    extends State<Step65ImagesNotValidatedPage> {
  void retryProcess() {
    // Opción alternativa: usar el método estático para navegar al Step3
    // pero primero necesitamos regresar al contexto de RegisterPage
    Navigator.of(context).popUntil(
        (route) => route.settings.name == '/register' || route.isFirst);

    // Luego navegar al Step3 usando el método estático
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RegisterPage.goToStep(context, 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 30, left: 16, right: 16),
              child: InfluyoLogo(),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ícono de error con círculo rojo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE), // Fondo rosa claro
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F), // Rojo
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text(
                      'Error al registrar las fotos',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Algo salió mal al intentar registrar las fotos de tu DNI o tu rostro.',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Esto puede deberse a que el documento no está completamente visible, hay reflejos o sombras, o tu rostro no está bien centrado.',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  onPressed: retryProcess,
                  child: const Text(
                    'Reintentar',
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
