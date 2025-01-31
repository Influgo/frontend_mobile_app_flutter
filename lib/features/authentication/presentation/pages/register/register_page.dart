import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/login/login_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step4_register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step4.5_register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step5_register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step6_register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step7_terms_conditions.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step8_register_page.dart';
import 'package:logger/logger.dart';
import 'select_profile_page.dart';
import 'step1_register_page.dart';
import 'step2_entrepreneur_register_page.dart';
import 'step2_influencer_register_page.dart';
import 'step3_register_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static void goToNextStep(BuildContext context, {Uint8List? image, double? step}) {
    final state = context.findAncestorStateOfType<_RegisterPageState>();
    state?._nextStep(image: image, step: step?.toInt());
  }

  static void updateRequestBody(BuildContext context, Map<String, dynamic> data) {
    final state = context.findAncestorStateOfType<_RegisterPageState>();
    state?._updateRequestBody(data);
  }

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  late List<Widget> _pages;
  String _selectedProfile = "";
  Map<String, dynamic> _requestBody = {};
  final Logger logger = Logger();

  Uint8List? _anversoImage;
  Uint8List? _reversoImage;
  Uint8List? _perfilImage;

  @override
  void initState() {
    super.initState();
    _pages = [
      SelectProfilePage(
        onNextStep: (profile) {
          _selectedProfile = profile;
          _initializePages();
        },
      ),
    ];
  }

  void _initializePages() {
    setState(() {
      _pages = [
        SelectProfilePage(
          onNextStep: (profile) {
            _selectedProfile = profile;
            _initializePages();
          },
        ),
      ];
      _currentStep = 0;

      if (_selectedProfile == "Influencer") {
        _pages.addAll([
          Step1RegisterPage(profile: _selectedProfile),
          const Step2InfluencerRegisterPage(),
          const Step3RegisterPage(),
          Step4RegisterPage(onImageCaptured: (image) {
            _anversoImage = image;
            logger.i('Anverso Image Captured');
          }),
          Step4_5RegisterPage(onImageCaptured: (image) {
            _reversoImage = image;
            logger.i('Reverso Image Captured');
          }),
          Step5RegisterPage(),
          Step6RegisterPage(onImageCaptured: (image) {
            _perfilImage = image;
            logger.i('Perfil Image Captured');
          }),
          Step7TermsConditionsPage(requestBody: _requestBody),
          const Step8RegisterPage(),
        ]);
      } else if (_selectedProfile == "Emprendedor") {
        _pages.addAll([
          Step1RegisterPage(profile: _selectedProfile),
          const Step2EntrepreneurRegisterPage(),
          const Step3RegisterPage(),
          Step4RegisterPage(onImageCaptured: (image) {
            _anversoImage = image;
            logger.i('Anverso Image Captured');
          }),
          Step4_5RegisterPage(onImageCaptured: (image) {
            _reversoImage = image;
            logger.i('Reverso Image Captured');
          }),
          Step5RegisterPage(),
          Step6RegisterPage(onImageCaptured: (image) {
            _perfilImage = image;
            logger.i('Perfil Image Captured');
          }),
          Step7TermsConditionsPage(requestBody: _requestBody),
          const Step8RegisterPage(),
        ]);
      }
    });
    _nextStep();
  }

  void _updateRequestBody(Map<String, dynamic> data) {
    setState(() {
      _requestBody.addAll(data);
      logger.i('Updated Request Body: $_requestBody');
    });
  }

  void _nextStep({Uint8List? image, int? step}) {
    if (image != null && step != null) {
      if (step == 4) {
        _anversoImage = image;
        logger.i('Anverso Image Captured');
      } else if (step == 4.5) {
        _reversoImage = image;
        logger.i('Reverso Image Captured');
      } else if (step == 6) {
        _perfilImage = image;
        logger.i('Perfil Image Captured');
      }
    }

    if (_currentStep == 8) {
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
          if (_currentStep >= 0 && _currentStep < 8)
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