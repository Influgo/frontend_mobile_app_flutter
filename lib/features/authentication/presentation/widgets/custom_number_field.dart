import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final int maxLength;

  const CustomNumberField({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength),
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFF8B1C7B)),
        ),
        errorText: errorText,
        counterText: "",
      ),
    );
  }
}
