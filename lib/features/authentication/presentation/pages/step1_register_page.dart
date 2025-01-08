import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register_page.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_number_field.dart';
import '../widgets/password_field.dart';
import '../widgets/error_text_widget.dart';

class Step1RegisterPage extends StatefulWidget {
  const Step1RegisterPage({super.key});

  @override
  State<Step1RegisterPage> createState() => _Step1RegisterPageState();
}

class _Step1RegisterPageState extends State<Step1RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  String? selectedDocumentType;
  String? firstNameError;
  String? lastNameError;
  String? documentTypeError;
  String? dniError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;

  void validateAndContinue() {
    setState(() {
      firstNameError = firstNameController.text.trim().isEmpty
          ? 'Nombres es requerido'
          : null;
      lastNameError = lastNameController.text.trim().isEmpty
          ? 'Apellidos es requerido'
          : null;
      documentTypeError = selectedDocumentType == null
          ? 'Tipo de documento de identidad es requerido'
          : null;
      dniError = dniController.text.trim().isEmpty
          ? 'DNI es requerido'
          : (dniController.text.trim().length != 8
              ? 'DNI debe tener 8 dígitos'
              : null);
      emailError = emailController.text.trim().isEmpty
          ? 'Correo es requerido'
          : (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(emailController.text.trim())
              ? 'Correo no es válido'
              : null);
      phoneError = phoneController.text.trim().isEmpty
          ? 'Celular es requerido'
          : (phoneController.text.trim().length != 9
              ? 'Celular debe tener 9 dígitos'
              : null);

      String password = passwordController.text.trim();
      if (password.isEmpty) {
        passwordError = 'Contraseña es requerida';
      } else if (password.length < 8 || password.length > 20) {
        passwordError = 'Contraseña debe tener entre 8 y 20 caracteres';
      } else if (!RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(password)) {
        passwordError =
            'Contraseña debe tener al menos una letra mayúscula y una minúscula';
      } else if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password)) {
        passwordError = 'Contraseña debe tener al menos un carácter especial';
      } else {
        passwordError = null;
      }

      String confirmPassword = confirmPasswordController.text.trim();
      if (confirmPassword.isEmpty) {
        confirmPasswordError = 'Confirmar contraseña es requerida';
      } else if (confirmPassword != password) {
        confirmPasswordError =
            'Confirmar contraseña debe ser igual a la contraseña';
      } else {
        confirmPasswordError = null;
      }

      if ([
        firstNameError,
        lastNameError,
        documentTypeError,
        dniError,
        emailError,
        phoneError,
        passwordError,
        confirmPasswordError
      ].every((error) => error == null)) {
        RegisterPage.goToNextStep(context);
      }
    });
    RegisterPage.goToNextStep(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    SvgPicture.asset(
                      'assets/images/influyo_logo.svg',
                      height: 25,
                    ),
                    const Spacer(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFC20B0C),
                                Color(0xFF7E0F9D),
                                Color(0xFF2616C7)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ingresa tus datos',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rellena los campos',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    children: [
                      CustomTextField(
                        label: 'Nombres',
                        controller: firstNameController,
                      ),
                      if (firstNameError != null)
                        ErrorTextWidget(error: firstNameError!),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Apellidos',
                        controller: lastNameController,
                      ),
                      if (lastNameError != null)
                        ErrorTextWidget(error: lastNameError!),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Tipo de documento de identidad',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedDocumentType,
                        items: const [
                          DropdownMenuItem(value: 'DNI', child: Text('DNI')),
                          DropdownMenuItem(
                              value: 'Pasaporte', child: Text('Pasaporte')),
                          DropdownMenuItem(
                              value: 'Cédula', child: Text('Cédula')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedDocumentType = value;
                          });
                        },
                      ),
                      if (documentTypeError != null)
                        ErrorTextWidget(error: documentTypeError!),
                      const SizedBox(height: 16),
                      CustomNumberField(
                        label: 'N° de documento de identidad',
                        controller: dniController,
                      ),
                      if (dniError != null) ErrorTextWidget(error: dniError!),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Correo',
                        controller: emailController,
                      ),
                      if (emailError != null)
                        ErrorTextWidget(error: emailError!),
                      const SizedBox(height: 16),
                      CustomNumberField(
                        label: 'Celular',
                        controller: phoneController,
                      ),
                      if (phoneError != null)
                        ErrorTextWidget(error: phoneError!),
                      const SizedBox(height: 16),
                      PasswordField(controller: passwordController),
                      if (passwordError != null)
                        ErrorTextWidget(error: passwordError!),
                      const SizedBox(height: 16),
                      PasswordField(controller: confirmPasswordController),
                      if (confirmPasswordError != null)
                        ErrorTextWidget(error: confirmPasswordError!),
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 30,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF222222),
                padding: const EdgeInsets.symmetric(vertical: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: validateAndContinue,
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}
