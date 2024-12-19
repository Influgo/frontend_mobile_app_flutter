import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentations/pages/login_page.dart';

void main() {
  runApp(const MyApp());
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
        textTheme: TextTheme(
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
      home: const LoginPage(),
    );
  }
}
