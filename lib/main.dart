import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_mobile_app_flutter/core/di/injection_container.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/login/login_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _clearStoredValues();

  setupDependencies();
  runApp(const MyApp());
}

Future<void> _clearStoredValues() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('first_name_register');
  await prefs.remove('last_name_register');
  await prefs.remove('dni_register');
  await prefs.remove('passport_register');
  await prefs.remove('carnet_register');
  await prefs.remove('email_register');
  await prefs.remove('phone_register');
  await prefs.remove('password_register');
  await prefs.remove('confirm_password_register');
  await prefs.remove('document_type_register');
  await prefs.remove('acceptTermsAndConditions');
  await prefs.remove('business_name_register');
  await prefs.remove('business_nickname_register');
  await prefs.remove('ruc_register');
  await prefs.remove('instagram_register');
  await prefs.remove('tiktok_register');
  await prefs.remove('youtube_register');
  await prefs.remove('twitch_register');
  await prefs.remove('show_instagram_field_register');
  await prefs.remove('show_tiktok_field_register');
  await prefs.remove('show_youtube_field_register');
  await prefs.remove('show_twitch_field_register');
  await prefs.remove('saved_image_path_doc_front');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Influyo!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
