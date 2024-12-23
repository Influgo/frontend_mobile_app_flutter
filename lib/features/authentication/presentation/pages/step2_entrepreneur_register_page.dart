import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_text_field.dart';

class Step2EntrepreneurRegisterPage extends StatefulWidget {
  const Step2EntrepreneurRegisterPage({super.key});

  @override
  State<Step2EntrepreneurRegisterPage> createState() => _Step2EntrepreneurRegisterPageState();
}

class _Step2EntrepreneurRegisterPageState extends State<Step2EntrepreneurRegisterPage> {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController rucController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController twitchController = TextEditingController();
  bool hasRUC = true;

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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
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
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ingresa los datos de tu emprendimiento',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    children: [
                      CustomTextField(
                        label: 'Nombre del emprendimiento',
                        controller: businessNameController,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¿Tu emprendimiento cuenta con RUC?',
                        style: TextStyle(fontSize: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: hasRUC,
                              activeColor: const Color(0xFF222222),
                              onChanged: (value) {
                                setState(() {
                                  hasRUC = value!;
                                });
                              },
                            ),
                            const Text(
                              'Sí',
                              style: TextStyle(color: Color(0xFF222222)),
                            ),
                            const SizedBox(width: 16),
                            Radio<bool>(
                              value: false,
                              groupValue: hasRUC,
                              activeColor: const Color(0xFF222222),
                              onChanged: (value) {
                                setState(() {
                                  hasRUC = value!;
                                });
                              },
                            ),
                            const Text(
                              'No',
                              style: TextStyle(color: Color(0xFF222222)),
                            ),
                          ],
                        ),
                      ),
                      if (!hasRUC) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Ingresa tus redes sociales',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ingresa el link de las redes sociales que administras',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Instagram',
                          controller: instagramController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Tiktok',
                          controller: tiktokController,
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Otras redes sociales (opcional)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Youtube',
                          controller: youtubeController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Twitch',
                          controller: twitchController,
                        ),
                      ] else
                        CustomTextField(
                          label: 'RUC',
                          controller: rucController,
                        ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: () {
                // next
              },
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