import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/gradient_bars.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_email_field.dart';
import '../../widgets/custom_number_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/error_text_widget.dart';

class Step1RegisterPage extends StatefulWidget {
  const Step1RegisterPage({super.key});

  @override
  State<Step1RegisterPage> createState() => _Step1RegisterPageState();
}

class _Step1RegisterPageState extends State<Step1RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController passportController = TextEditingController();
  final TextEditingController carnetController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  String? selectedDocumentType = 'dni';
  String? firstNameError;
  String? lastNameError;
  String? documentTypeError;
  String? documentError;
  String? passporteError;
  String? carnetError;
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
      if (selectedDocumentType == 'dni') {
        documentError = dniController.text.trim().isEmpty
            ? 'N° de Documento es requerido'
            : (dniController.text.trim().length != 8
                ? 'DNI debe tener 8 dígitos'
                : null);
      } else if (selectedDocumentType == 'pasaporte') {
        documentError = passportController.text.trim().isEmpty
            ? 'N° de Documento es requerido'
            : (passportController.text.trim().length != 12
                ? 'Pasaporte debe tener 12 dígitos'
                : null);
      } else if (selectedDocumentType == 'carnetExtranjeria') {
        documentError = carnetController.text.trim().isEmpty
            ? 'N° de Documento es requerido'
            : (carnetController.text.trim().length != 12
                ? 'Carnet de Extranjería debe tener 12 dígitos'
                : null);
      } else {
        documentError = null;
      }
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
        documentError,
        emailError,
        phoneError,
        passwordError,
        confirmPasswordError
      ].every((error) => error == null)) {
        RegisterPage.goToNextStep(context);
      }
    });
    // Descomentar para realizar pruebas sin validaciones:
    //RegisterPage.goToNextStep(context);
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
                const InfluyoLogo(),
                GradientBars(barCount: 1),
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      children: [
                        CustomTextField(
                          label: 'Nombres',
                          controller: firstNameController,
                          maxLength: 100,
                        ),
                        if (firstNameError != null)
                          ErrorTextWidget(error: firstNameError!),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Apellidos',
                          controller: lastNameController,
                          maxLength: 100,
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
                            DropdownMenuItem(value: 'dni', child: Text('DNI')),
                            DropdownMenuItem(
                                value: 'pasaporte', child: Text('Pasaporte')),
                            DropdownMenuItem(
                                value: 'carnetExtranjeria',
                                child: Text('Carnet de Extranjería')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedDocumentType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (selectedDocumentType == 'dni')
                          CustomNumberField(
                            label: 'DNI',
                            controller: dniController,
                            maxLength: 8,
                          ),
                        if (selectedDocumentType == 'pasaporte')
                          CustomNumberField(
                            label: 'N° de Pasaporte',
                            controller: passportController,
                            maxLength: 12,
                          ),
                        if (selectedDocumentType == 'carnetExtranjeria')
                          CustomNumberField(
                            label: 'N° de Carnet de Extranjería',
                            controller: carnetController,
                            maxLength: 12,
                          ),
                        if (documentError != null)
                          ErrorTextWidget(error: documentError!),
                        const SizedBox(height: 16),
                        CustomEmailField(
                          label: 'Correo',
                          controller: emailController,
                          maxLength: 100,
                        ),
                        if (emailError != null)
                          ErrorTextWidget(error: emailError!),
                        const SizedBox(height: 16),
                        CustomNumberField(
                          label: 'Celular',
                          controller: phoneController,
                          maxLength: 9,
                        ),
                        if (phoneError != null)
                          ErrorTextWidget(error: phoneError!),
                        const SizedBox(height: 16),
                        PasswordField(
                          controller: passwordController,
                          label: "Contraseña",
                        ),
                        if (passwordError != null)
                          ErrorTextWidget(error: passwordError!),
                        const SizedBox(height: 16),
                        PasswordField(
                          controller: confirmPasswordController,
                          label: "Confirmar contraseña",
                        ),
                        if (confirmPasswordError != null)
                          ErrorTextWidget(error: confirmPasswordError!),
                      ],
                    ),
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
