import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomNameField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final int maxLength;

  const CustomNameField({
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
      keyboardType: TextInputType.text,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength),
        FilteringTextInputFormatter.allow(
          RegExp(r"[a-zA-Z' -]"),
        ),
      ],
      onChanged: (value) {
        String newValue = value;

        newValue = _capitalizeWords(newValue);

        if (newValue != value) {
          controller.value = TextEditingValue(
            text: newValue,
            selection: TextSelection.collapsed(offset: newValue.length),
          );
        }
      },
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

  String _capitalizeWords(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
