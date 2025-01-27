import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/step1_forgot_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/step2_forgot_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/step3_forgot_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/step4_forgot_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/login/login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  static void goToNextStep(BuildContext context) {
    final state = context.findAncestorStateOfType<_ForgotPasswordPageState>();
    state?._nextStep();
  }

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Step1ForgotPasswordPage(onNextStep: _nextStep),
      const Step2ForgotPasswordPage(),
      const Step3ForgotPasswordPage(),
      const Step4ForgotPasswordPage(),
    ];
  }

  void _nextStep() {
    if (_currentStep == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      setState(() {
        _currentStep++;
      });
      _pageController.jumpToPage(_currentStep);
    }
  }

  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      setState(() {
        _currentStep--;
      });
      _pageController.jumpToPage(_currentStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          if (_currentStep >= 0)
            Positioned(
              top: 30,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                onPressed: _previousStep,
              ),
            ),
        ],
      ),
    );
  }
}
