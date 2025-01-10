import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final Function(String)? onChanged; // Nuevo parámetro onChanged

  const CustomInput({
    Key? key,
    required this.label,
    required this.controller,
    this.errorText,
    this.onChanged, // Se incluye como opcional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged, // Vinculación con el evento onChanged
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
      ),
    );
  }
}
