import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/gradient_bars.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_name_field.dart';
import '../../widgets/custom_email_field.dart';
import '../../widgets/custom_number_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/error_text_widget.dart';
import 'package:http/http.dart' as http;

class Step1RegisterPage extends StatefulWidget {
  final String profile;
  const Step1RegisterPage({super.key, required this.profile});

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
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isProcessing = false;

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      firstNameController.text = prefs.getString('first_name_register') ?? '';
      lastNameController.text = prefs.getString('last_name_register') ?? '';
      dniController.text = prefs.getString('dni_register') ?? '';
      passportController.text = prefs.getString('passport_register') ?? '';
      carnetController.text = prefs.getString('carnet_register') ?? '';
      emailController.text = prefs.getString('email_register') ?? '';
      phoneController.text = prefs.getString('phone_register') ?? '';
      passwordController.text = prefs.getString('password_register') ?? '';
      confirmPasswordController.text =
          prefs.getString('confirm_password_register') ?? '';
      selectedDocumentType = prefs.getString('document_type_register') ?? 'dni';
    });
  }

  Future<void> _saveDataLocally() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('first_name_register', firstNameController.text);
    await prefs.setString('last_name_register', lastNameController.text);
    await prefs.setString('dni_register', dniController.text);
    await prefs.setString('passport_register', passportController.text);
    await prefs.setString('carnet_register', carnetController.text);
    await prefs.setString('email_register', emailController.text);
    await prefs.setString('phone_register', phoneController.text);
    await prefs.setString('password_register', passwordController.text);
    await prefs.setString(
        'confirm_password_register', confirmPasswordController.text);
    await prefs.setString(
        'document_type_register', selectedDocumentType ?? 'dni');
  }

  Future<bool> validateEmail(String email) async {
    final response = await http.get(Uri.parse(
        'https://influyo-testing.ryzeon.me/api/v1/users/check-email/$email'));
    return response.statusCode == 400;
  }

  Future<bool> validateDocument(String document) async {
    final response = await http.get(Uri.parse(
        'https://influyo-testing.ryzeon.me/api/v1/users/check-document/$document'));
    return response.statusCode == 400;
  }

  Future<bool> validateCellphone(String cellphone) async {
    final response = await http.get(Uri.parse(
        'https://influyo-testing.ryzeon.me/api/v1/users/check-cellphone/$cellphone'));
    return response.statusCode == 400;
  }

  void validateAndContinue() async {
    if (isProcessing) return;
    setState(() { isProcessing = true; });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('acceptTermsAndConditions', false);

    setState(() {
      firstNameError = firstNameController.text.trim().isEmpty ? 'Nombres es requerido' : null;
      lastNameError = lastNameController.text.trim().isEmpty ? 'Apellidos es requerido' : null;
      documentTypeError = selectedDocumentType == null ? 'Tipo de documento de identidad es requerido' : null;

      if (selectedDocumentType == 'dni') {
        documentError = dniController.text.trim().isEmpty
            ? 'N° de Documento es requerido'
            : (dniController.text.trim().length != 8 ? 'DNI debe tener 8 dígitos' : null);
      } else if (selectedDocumentType == 'pasaporte') {
        documentError = passportController.text.trim().isEmpty
            ? 'N° de Documento es requerido'
            : (passportController.text.trim().length != 12 ? 'Pasaporte debe tener 12 dígitos' : null);
      } else if (selectedDocumentType == 'carnetExtranjeria') {
        documentError = carnetController.text.trim().isEmpty
            ? 'N° de Documento es requerido'
            : (carnetController.text.trim().length != 12 ? 'Carnet de Extranjería debe tener 12 dígitos' : null);
      } else {
        documentError = null;
      }

      final email = emailController.text.trim();
      if (email.isEmpty) {
        emailError = 'Correo es requerido';
      } else if (!emailRegExp.hasMatch(email)) {
        emailError = 'Correo no es válido';
      } else {
        emailError = null;
      }

      phoneError = phoneController.text.trim().isEmpty
          ? 'Celular es requerido'
          : (phoneController.text.trim().length != 9 ? 'Celular debe tener 9 dígitos' : null);

      String password = passwordController.text.trim();
      if (password.isEmpty) {
        passwordError = 'Contraseña es requerida';
      } else if (password.length < 8 || password.length > 20) {
        passwordError = 'Contraseña debe tener entre 8 y 20 caracteres';
      } else if (!RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(password)) {
        passwordError = 'Contraseña debe tener al menos una letra mayúscula y una minúscula';
      } else if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password)) {
        passwordError = 'Contraseña debe tener al menos un carácter especial';
      } else {
        passwordError = null;
      }

      String confirmPassword = confirmPasswordController.text.trim();
      if (confirmPassword.isEmpty) {
        confirmPasswordError = 'Confirmar contraseña es requerida';
      } else if (confirmPassword != password) {
        confirmPasswordError = 'Confirmar contraseña debe ser igual a la contraseña';
      } else {
        confirmPasswordError = null;
      }
    });

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
      final email = emailController.text.trim();
      final document = selectedDocumentType == 'dni'
          ? dniController.text.trim()
          : selectedDocumentType == 'pasaporte'
          ? passportController.text.trim()
          : carnetController.text.trim();
      final cellphone = phoneController.text.trim();

      final isEmailValid = await validateEmail(email);
      final isDocumentValid = await validateDocument(document);
      final isCellphoneValid = await validateCellphone(cellphone);

      if (!isEmailValid) setState(() => emailError = 'El correo ya está registrado');
      if (!isDocumentValid) setState(() => documentError = 'El documento ya está registrado');
      if (!isCellphoneValid) setState(() => phoneError = 'El celular ya está registrado');

      if (isEmailValid && isDocumentValid && isCellphoneValid) {
        var logger = Logger();
        Map<String, dynamic> requestBody = {
          "names": firstNameController.text.trim(),
          "lastNames": lastNameController.text.trim(),
          "identificationType": selectedDocumentType == 'dni' ? 1 : 0,
          "identificationNumber": document,
          "email": email,
          "phoneNumber": cellphone,
          "password": passwordController.text.trim(),
        };
        logger.i('Request Body: $requestBody');
        _saveDataLocally();
        RegisterPage.updateRequestBody(context, requestBody);
        FocusScope.of(context).unfocus();
        RegisterPage.goToNextStep(context);
      }
    }

    setState(() { isProcessing = false; });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dniController.dispose();
    passportController.dispose();
    carnetController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 8), // <-- Reducido bottom
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InfluyoLogo(),
            GradientBars(barCount: 1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ingresa tus datos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                children: [
                  CustomNameField(
                    label: 'Nombres',
                    controller: firstNameController,
                    maxLength: 100,
                  ),
                  if (firstNameError != null)
                    ErrorTextWidget(error: firstNameError!),
                  const SizedBox(height: 16),
                  CustomNameField(
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
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recuerda que tu contraseña debe incluir:',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 8.0),
                              child: Icon(Icons.circle, size: 8),
                            ),
                            Expanded(
                              child: Text(
                                'Entre 8 y 20 caracteres',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 8.0),
                              child: Icon(Icons.circle, size: 8),
                            ),
                            Expanded(
                              child: Text(
                                'Al menos 1 letra mayúscula y 1 letra minúscula',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 8.0),
                              child: Icon(Icons.circle, size: 8),
                            ),
                            Expanded(
                              child: Text(
                                '1 o más caracteres especiales',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18), // <-- Espacio inferior ajustado
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF222222),
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: isProcessing ? null : validateAndContinue,
                      child: isProcessing
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Continuar',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), // <-- Solo un pequeño margen final
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
