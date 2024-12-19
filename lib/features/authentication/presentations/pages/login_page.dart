import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _validateAndLogin() {
    setState(() {
      // lógica auth, revisar en figma (pendiente el acceso)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo centrado
            Center(
              child: Image.asset(
                'assets/images/influyo_logo.jpg',
                height: 30,   
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 80), // Espacio entre el logo y el texto
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ingresa tus datos para acceder a tu cuenta',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Correo o teléfono',
              controller: _identifierController,
            ),
            const SizedBox(height: 16),
            PasswordField(controller: _passwordController),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return const Color.fromARGB(255, 35, 120, 172);
                    }
                    return const Color.fromARGB(255, 45, 140, 192);
                  }),
                  animationDuration: const Duration(milliseconds: 100),
                ),
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Color.fromARGB(255, 45, 140, 192),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _validateAndLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Ingresar como invitado',
                style: TextStyle(
                  color: Color(0xFF6A6A6A),
                  decoration: TextDecoration.underline,
                  decorationColor: Color.fromARGB(255, 137, 136, 136),
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: Text.rich(
                TextSpan(
                  text: '¿No tienes una cuenta? ',
                  style: const TextStyle(color: Color(0xFF6A6A6A)),
                  children: [
                    TextSpan(
                      text: 'Regístrate',
                      style: const TextStyle(
                        color: Color(0xFF6A6A6A),
                        decoration: TextDecoration.underline,
                        decorationColor: Color.fromARGB(255, 137, 136, 136),
                      ),
                    ),
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
