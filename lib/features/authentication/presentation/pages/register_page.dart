import 'package:flutter/material.dart';
import 'select_profile_page.dart';
import 'step1_entrepreneur_register_page.dart';
import 'step2_entrepreneur_register_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static void goToNextStep(BuildContext context) {
    final state = context.findAncestorStateOfType<_RegisterPageState>();
    state?._nextStep();
  }
  
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SelectProfilePage(onNextStep: _nextStep),
      const Step1EntrepreneurRegisterPage(),
      const Step2EntrepreneurRegisterPage(),
    ];
  }

  void _nextStep() {
    if (_currentStep < _pages.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.jumpToPage(_currentStep);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
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
          if (_currentStep > 0)
            Positioned(
              top: 30,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
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