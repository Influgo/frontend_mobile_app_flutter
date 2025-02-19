import 'package:flutter/material.dart';

class PasswordRequirementRow extends StatelessWidget {
  final String text;
  final bool isValid;

  const PasswordRequirementRow({
    super.key,
    required this.text,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
