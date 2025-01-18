import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final Function(String)? onChanged;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.onChanged,
  });

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label, // Usar el texto personalizado
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFF8B1C7B)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        errorText: widget.errorText,
      ),
    );
  }
}
