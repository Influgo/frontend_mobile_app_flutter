import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/login_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/form_button.dart';

class Step8ReviewPage extends StatelessWidget {
  final String title;
  final String subtitle; 
  final String buttonText;

  const Step8ReviewPage({
    super.key,
    this.title = 'Tu perfil está en revisión',
    this.subtitle = 'Te avisaremos de su aprobación dentro de\n12hrs hábiles. Por mientras explora lo que te ofrece Influyo!',
    this.buttonText = 'Explorar',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Contenedor circular con el GIF
                Container(
                  width: 180, // Tamaño del círculo
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100, // Fondo amarillo
                    shape: BoxShape.circle, // Forma circular
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0), // Espaciado interno
                    child: Image.asset(
                      'assets/images/review.gif',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(flex: 2),
                FormButton(
                  text: buttonText,
                  isEnabled: true,
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
