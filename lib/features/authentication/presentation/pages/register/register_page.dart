import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/data/models/validation_data.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/login/login_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step4_register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step4.5_register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step5_register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step6_register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step6.5_images_validated.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step6.5_images_not_validated.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step7_terms_conditions.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/step8_register_page.dart';
import 'package:logger/logger.dart';
import 'select_profile_page.dart';
import 'step1_register_page.dart';
import 'step2_entrepreneur_register_page.dart';
import 'step2_influencer_register_page.dart';
import 'step3_register_page.dart';

class RegisterPage extends StatefulWidget {
  final int? initialStep;

  const RegisterPage({super.key, this.initialStep});

  static void goToNextStep(BuildContext context,
      {Uint8List? image, double? step}) {
    final state = context.findAncestorStateOfType<_RegisterPageState>();
    state?._nextStep();
  }

  static void goToStep(BuildContext context, int step) {
    final state = context.findAncestorStateOfType<_RegisterPageState>();
    if (state != null) {
      state._goToSpecificStep(step);
    }
  }

  static void updateRequestBody(
      BuildContext context, Map<String, dynamic> data) {
    final state = context.findAncestorStateOfType<_RegisterPageState>();
    state?._updateRequestBody(data);
  }

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();
  final ValidationData _validationData = ValidationData();
  final Logger logger = Logger();

  int _currentStep = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SelectProfilePage(
        onNextStep: (profile) {
          setState(() {
            _validationData.selectedProfile = profile;
            _initializePages();
          });
        },
      ),
    ];

    // Si se especifica un step inicial, navegar a él después de la inicialización
    if (widget.initialStep != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _goToSpecificStep(widget.initialStep!);
      });
    }
  }

  void _initializePages() {
    setState(() {
      _pages = [
        SelectProfilePage(
          onNextStep: (profile) {
            _validationData.selectedProfile = profile;
            _initializePages();
          },
        ),
      ];
      _currentStep = 0;

      if (_validationData.selectedProfile == "Influencer") {
        _pages.addAll(_getInfluencerSteps());
      } else if (_validationData.selectedProfile == "Emprendedor") {
        _pages.addAll(_getEntrepreneurSteps());
      }
    });
    _nextStep();
  }

  List<Widget> _getInfluencerSteps() {
    return [
      Step1RegisterPage(profile: _validationData.selectedProfile),
      const Step2InfluencerRegisterPage(),
      const Step3RegisterPage(),
      Step4RegisterPage(onImageCaptured: (image) {
        setState(() => _validationData.anversoImage = image);
        logger.i('Anverso Image Captured');
      }),
      Step4_5RegisterPage(onImageCaptured: (image) {
        setState(() => _validationData.reversoImage = image);
        logger.i('Reverso Image Captured');
      }),
      Step5RegisterPage(),
      Step6RegisterPage(
        onImageCaptured: (image) {
          setState(() => _validationData.perfilImage = image);
          logger.i('Perfil Image Captured');
        },
        validationData: _validationData,
      ),
      // NOTA: Step6.5 pages se manejan por navegación directa desde Step6
      // No se incluyen en el PageView ya que usan Navigator.pushReplacement
      Step7TermsConditionsPage(
        requestBody: _validationData.requestBody,
        validationData: _validationData,
      ),
      const Step8RegisterPage(),
    ];
  }

  List<Widget> _getEntrepreneurSteps() {
    return [
      Step1RegisterPage(profile: _validationData.selectedProfile),
      const Step2EntrepreneurRegisterPage(),
      const Step3RegisterPage(),
      Step4RegisterPage(onImageCaptured: (image) {
        setState(() => _validationData.anversoImage = image);
        logger.i('Anverso Image Captured');
      }),
      Step4_5RegisterPage(onImageCaptured: (image) {
        setState(() => _validationData.reversoImage = image);
        logger.i('Reverso Image Captured');
      }),
      Step5RegisterPage(),
      Step6RegisterPage(
        onImageCaptured: (image) {
          setState(() => _validationData.perfilImage = image);
          logger.i('Perfil Image Captured');
        },
        validationData: _validationData,
      ),
      // NOTA: Step6.5 pages se manejan por navegación directa desde Step6
      // No se incluyen en el PageView ya que usan Navigator.pushReplacement
      Step7TermsConditionsPage(
        requestBody: _validationData.requestBody,
        validationData: _validationData,
      ),
      const Step8RegisterPage(),
    ];
  }

  void _updateRequestBody(Map<String, dynamic> data) {
    setState(() {
      _validationData.requestBody.addAll(data);
      logger.i('Updated Request Body: ${_validationData.requestBody}');
    });
  }

  void _goToSpecificStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.jumpToPage(_currentStep);
  }

  void _nextStep() {
    if (_currentStep == 10) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      setState(() => _currentStep++);
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
          if (_currentStep >= 0 && _currentStep < 9)
            SafeArea(
              child: Positioned(
                top: 30,
                left: 16,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                    onPressed: _previousStep,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
