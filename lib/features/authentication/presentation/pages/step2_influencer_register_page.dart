import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/pages/register_page.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_text_widget.dart';

class Step2InfluencerRegisterPage extends StatefulWidget {
  const Step2InfluencerRegisterPage({super.key});

  @override
  State<Step2InfluencerRegisterPage> createState() =>
      _Step2InfluencerRegisterPageState();
}

class _Step2InfluencerRegisterPageState
    extends State<Step2InfluencerRegisterPage> {
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController twitchController = TextEditingController();

  String? instagramEmpty;
  String? tiktokEmpty;

  void validateAndContinue() {
    setState(() {
      instagramEmpty = instagramController.text.trim().isEmpty
          ? 'Link de Instagram es requerido'
          : null;
      tiktokEmpty = tiktokController.text.trim().isEmpty
          ? 'Link de TikTok es requerido'
          : null;
      if ([instagramEmpty, tiktokEmpty].every((error) => error == null)) {
        RegisterPage.goToNextStep(context);
      }
    });
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
                                Color(0xFF2616C7),
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
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFC20B0C),
                                Color(0xFF7E0F9D),
                                Color(0xFF2616C7),
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
                    ],
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ingresa tus redes sociales',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0.0),
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Ingresa el link de las redes sociales que manejas',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                          label: 'Instagram',
                          controller: instagramController,
                          maxLength: 100),
                      if (instagramEmpty != null)
                        ErrorTextWidget(error: instagramEmpty!),
                      const SizedBox(height: 16),
                      CustomTextField(
                          label: 'Tiktok',
                          controller: tiktokController,
                          maxLength: 100),
                      if (tiktokEmpty != null)
                        ErrorTextWidget(error: tiktokEmpty!),
                      const SizedBox(height: 32),
                      const Text(
                        'Otras redes sociales (opcional)',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                          label: 'Youtube',
                          controller: youtubeController,
                          maxLength: 100),
                      const SizedBox(height: 16),
                      CustomTextField(
                          label: 'Twitch',
                          controller: twitchController,
                          maxLength: 100),
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
          ),
        ],
      ),
    );
  }
}
