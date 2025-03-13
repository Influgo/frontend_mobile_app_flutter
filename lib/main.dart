import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mobile_app_flutter/core/data/local/shared_preferences_service.dart';
import 'package:frontend_mobile_app_flutter/core/di/injection_container.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/login/login_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final sharedPreferencesService = SharedPreferencesService();
  await sharedPreferencesService.clearStoredValues();

  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

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
            '/login': (context) =>
                _buildRotatedScreen(const LoginPage(), isLandscape),
                // HomePage(),
              
            '/register': (context) =>
                _buildRotatedScreen(const RegisterPage(), isLandscape),
          },
        );
      },
    );
  }

  Widget _buildRotatedScreen(Widget child, bool isLandscape) {
    return isLandscape ? RotatedBox(quarterTurns: -1, child: child) : child;
  }
}
