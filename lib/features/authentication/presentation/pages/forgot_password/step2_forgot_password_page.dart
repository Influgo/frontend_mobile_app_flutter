import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mobile_app_flutter/core/di/injection_container.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/domain/usecases/check_token_usecase.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/domain/usecases/forgot_password_usecase.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/forgot_password/forgot_password_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Step2ForgotPasswordPage extends StatefulWidget {
  const Step2ForgotPasswordPage({super.key});

  @override
  State<Step2ForgotPasswordPage> createState() =>
      _Step2ForgotPasswordPageState();
}

class _Step2ForgotPasswordPageState extends State<Step2ForgotPasswordPage> {
  final List<TextEditingController> controllers = List.generate(
    5,
        (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(
    5,
        (index) => FocusNode(),
  );

  late final ForgotPasswordUseCase _forgotPasswordUseCase;
  late final CheckTokenUseCase _checkTokenUseCase;
  String userEmail = '';
  bool showError = false;
  Timer? _timer;
  int _remainingTime = 60;
  bool _canResend = false;
  OverlayEntry? _buttonOverlay;

  @override
  void initState() {
    super.initState();
    _forgotPasswordUseCase = getIt<ForgotPasswordUseCase>();
    _checkTokenUseCase = getIt<CheckTokenUseCase>();
    _loadSavedEmail();
    _startTimer();

    // Crear el overlay del botón después de que se construya el frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createButtonOverlay();
    });
  }

  @override
  void dispose() {
    _buttonOverlay?.remove();
    _timer?.cancel();
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
          _canResend = false;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _remainingTime = 60;
      _canResend = false;
    });
    _startTimer();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email_forgot_password') ?? '';
    });
  }

  void onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 4) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    setState(() => showError = false);
    _saveVerificationCode();
  }

  Future<void> _saveVerificationCode() async {
    final code = controllers.map((c) => c.text).join();
    if (code.length == 5) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('verification_code_forgot_password', code);
    }
  }

  Future<void> _resendCode() async {
    try {
      await _forgotPasswordUseCase.execute(userEmail);
      _resetTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código reenviado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reenviar código: ${e.toString()}')),
      );
    }
  }

  Future<void> _validateAndContinue() async {
    final allFilled =
    controllers.every((controller) => controller.text.length == 1);

    if (allFilled) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('verification_code_forgot_password') ?? '';

      try {
        final response = await _checkTokenUseCase.execute(token);

        if (response.statusCode == 200) {
          ForgotPasswordPage.goToNextStep(context);
        } else if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código de verificación inválido')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error en el servidor')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      setState(() => showError = true);
    }
  }

  void _createButtonOverlay() {
    _buttonOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: 30,
        right: 30,
        bottom: 16,
        child: Material(
          color: Colors.transparent,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF222222),
              padding: const EdgeInsets.symmetric(vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: _validateAndContinue,
            child: const Text(
              'Siguiente',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_buttonOverlay!);
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  bool _isCodeComplete() {
    return controllers.every((controller) => controller.text.length == 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 60,
          left: 16,
          right: 16,
          bottom: 120, // Espacio para que el overlay del botón no tape el contenido
        ),
        child: Column(
          children: [
            const InfluyoLogo(),
            const Padding(
              padding: EdgeInsets.only(top: 30, left: 16, right: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cambiar contraseña',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ingresa el código de verificación de 5 dígitos enviado a $userEmail',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                    (index) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: showError ? Colors.red : Colors.grey[300]!,
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textInputAction: index == 4 ? TextInputAction.done : TextInputAction.next,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => onCodeChanged(value, index),
                    onSubmitted: (value) {
                      if (index == 4 && _isCodeComplete()) {
                        _validateAndContinue();
                      }
                    },
                  ),
                ),
              ),
            ),
            if (showError)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Por favor completa todos los dígitos',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _canResend ? _resendCode : null,
                child: Text(
                  _canResend
                      ? 'Reenviar código'
                      : 'Reenviar código en ${_formatTime(_remainingTime)}',
                  style: TextStyle(
                    color: _canResend ? Colors.blue : Colors.grey[600],
                    fontSize: 14,
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