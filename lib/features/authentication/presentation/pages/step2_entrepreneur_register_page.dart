import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register_page.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_email_field.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_username_field.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/form_separator.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/gradient_bars.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/influyo_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_number_field.dart';
import '../widgets/error_text_widget.dart';

class Step2EntrepreneurRegisterPage extends StatefulWidget {
  const Step2EntrepreneurRegisterPage({super.key});

  @override
  State<Step2EntrepreneurRegisterPage> createState() =>
      _Step2EntrepreneurRegisterPageState();
}

class _Step2EntrepreneurRegisterPageState
    extends State<Step2EntrepreneurRegisterPage> {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessNicknameController =
      TextEditingController();
  final TextEditingController rucController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController twitchController = TextEditingController();

  bool showInstagramField = false;
  bool showTiktokField = false;
  bool showYoutubeField = false;
  bool showTwitchField = false;

  String? businessNameEmpty;
  String? businessNicknameEmpty;
  String? rucEmpty;
  String? socialMediaEmpty;
  String? instagramEmpty;
  String? tiktokEmpty;
  String? youtubeEmpty;
  String? twitchEmpty;

  void validateAndContinue() {
    setState(() {
      businessNameEmpty = businessNameController.text.trim().isEmpty
          ? 'Nombre del emprendimiento es requerido'
          : null;
      businessNicknameEmpty = businessNicknameController.text.trim().isEmpty
          ? 'Nickname del emprendimiento es requerido'
          : null;
      rucEmpty = rucController.text.trim().isEmpty
          ? 'RUC es requerido'
          : (rucController.text.trim().length != 11
              ? 'RUC debe tener 11 dígitos'
              : null);

      if (!showInstagramField && !showTiktokField) {
        socialMediaEmpty =
            'Debe seleccionar al menos Instagram o Tiktok como red social';
      } else {
        socialMediaEmpty = null;
        if (showInstagramField && instagramController.text.trim().isEmpty) {
          instagramEmpty = 'Debe ingresar su usuario de Instagram';
        } else {
          instagramEmpty = null;
        }

        if (showTiktokField && tiktokController.text.trim().isEmpty) {
          tiktokEmpty = 'Debe ingresar su usuario de Tiktok';
        } else {
          tiktokEmpty = null;
        }
      }

      if (showYoutubeField && youtubeController.text.trim().isEmpty) {
        youtubeEmpty = 'Debe ingresar su canal de Youtube';
      } else {
        youtubeEmpty = null;
      }
      if (showTwitchField && twitchController.text.trim().isEmpty) {
        twitchEmpty = 'Debe ingresar su canal de Twitch';
      } else {
        twitchEmpty = null;
      }

      if ([
        businessNameEmpty,
        businessNicknameEmpty,
        rucEmpty,
        socialMediaEmpty,
        instagramEmpty,
        tiktokEmpty,
        youtubeEmpty,
        twitchEmpty
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
                GradientBars(barCount: 2),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ingresa los datos de tu emprendimiento',
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
                          horizontal: 16.0, vertical: 20.0),
                      children: [
                        CustomTextField(
                            label: 'Nombre del emprendimiento',
                            controller: businessNameController,
                            maxLength: 100),
                        if (businessNameEmpty != null)
                          ErrorTextWidget(error: businessNameEmpty!),
                        const SizedBox(height: 16),
                        CustomEmailField(
                            label: 'Nickname del emprendimiento',
                            controller: businessNicknameController,
                            maxLength: 100),
                        if (businessNicknameEmpty != null)
                          ErrorTextWidget(error: businessNicknameEmpty!),
                        const SizedBox(height: 16),
                        CustomNumberField(
                          label: 'RUC',
                          controller: rucController,
                          maxLength: 11,
                        ),
                        if (rucEmpty != null) ErrorTextWidget(error: rucEmpty!),
                        const SizedBox(height: 16),
                        const Text(
                          'Ingresa tus redes sociales',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ingresa el usuario de las redes sociales que administras',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Instagram',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            Checkbox(
                              value: showInstagramField,
                              onChanged: (bool? value) {
                                setState(() {
                                  showInstagramField = value ?? false;
                                });
                              },
                              activeColor: Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (showInstagramField) ...[
                          CustomUsernameField(
                            label: 'Usuario de Instagram',
                            controller: instagramController,
                            maxLength: 100,
                          ),
                          if (instagramEmpty != null)
                            ErrorTextWidget(error: instagramEmpty!),
                          const SizedBox(height: 8),
                        ],
                        const FormSeparator(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tiktok',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            Checkbox(
                              value: showTiktokField,
                              onChanged: (bool? value) {
                                setState(() {
                                  showTiktokField = value ?? false;
                                });
                              },
                              activeColor: Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (showTiktokField) ...[
                          CustomUsernameField(
                            label: 'Usuario de Tiktok',
                            controller: tiktokController,
                            maxLength: 100,
                          ),
                          if (tiktokEmpty != null)
                            ErrorTextWidget(error: tiktokEmpty!),
                        ],
                        if (socialMediaEmpty != null)
                          ErrorTextWidget(error: socialMediaEmpty!),
                        const SizedBox(height: 16),
                        const Text(
                          'Otras redes sociales (opcional)',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Youtube',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            Checkbox(
                              value: showYoutubeField,
                              onChanged: (bool? value) {
                                setState(() {
                                  showYoutubeField = value ?? false;
                                });
                              },
                              activeColor: Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (showYoutubeField) ...[
                          CustomUsernameField(
                            label: 'Canal de Youtube',
                            controller: youtubeController,
                            maxLength: 100,
                          ),
                          if (youtubeEmpty != null)
                            ErrorTextWidget(error: youtubeEmpty!),
                          const SizedBox(height: 8),
                        ],
                        const FormSeparator(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Twitch',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            Checkbox(
                              value: showTwitchField,
                              onChanged: (bool? value) {
                                setState(() {
                                  showTwitchField = value ?? false;
                                });
                              },
                              activeColor: Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (showTwitchField) ...[
                          CustomUsernameField(
                            label: 'Canal de Twitch',
                            controller: twitchController,
                            maxLength: 100,
                          ),
                          if (twitchEmpty != null)
                            ErrorTextWidget(error: twitchEmpty!),
                        ],
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
          ),
        ],
      ),
    );
  }
}
