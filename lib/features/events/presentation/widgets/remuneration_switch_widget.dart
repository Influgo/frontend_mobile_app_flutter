import 'package:flutter/material.dart';

class RemunerationSwitchWidget extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const RemunerationSwitchWidget({
    super.key,
    required this.isPublic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isPublic,
                activeColor: Colors.blue,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              "¿Mostrar remuneración?",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
