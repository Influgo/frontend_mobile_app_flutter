import 'package:flutter/material.dart';

class HoverableElevatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const HoverableElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<HoverableElevatedButton> createState() => _HoverableElevatedButtonState();
}

class _HoverableElevatedButtonState extends State<HoverableElevatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 0),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _isHovered
              ? const LinearGradient(
                  colors: [
                    Color(0xFFC20B0C),
                    Color(0xFF7E0F9D),
                    Color(0xFF2616C7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: _isHovered ? null : Colors.white,
          border: Border.all(
            color: _isHovered ? Colors.transparent : const Color(0xFF222222),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            foregroundColor: _isHovered ? Colors.white : const Color(0xFF222222),
          ),
          onPressed: widget.onPressed,
          child: Text(
            widget.text,
            style: TextStyle(
              color: _isHovered ? Colors.white : const Color(0xFF222222),
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}