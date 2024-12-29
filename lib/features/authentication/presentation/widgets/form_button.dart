import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const FormButton({
    Key? key,
    required this.text,
    required this.isEnabled,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: isEnabled ? Colors.black : Colors.grey[300], // Color del texto
        minimumSize: const Size(double.infinity, 50), 
       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
