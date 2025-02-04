import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomUsernameField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final int maxLength;
  final FocusNode? focusNode;

  const CustomUsernameField({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
    required this.maxLength,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLength: maxLength - 1,
      keyboardType: TextInputType.text,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength - 1),
        FilteringTextInputFormatter.allow(
          RegExp(r"[a-zA-Z0-9._-]"),
        ),
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
        prefix: const Text(
          "@",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
