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
  State<HoverableElevatedButton> createState() =>
      _HoverableElevatedButtonState();
}

class _HoverableElevatedButtonState extends State<HoverableElevatedButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _handlePress() async {
    setState(() {
      _isPressed = true;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      _isPressed = false;
    });

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = _isHovered || _isPressed;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => _handlePress(),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border:
                isActive ? null : Border.all(color: const Color(0xFF222222)),
          ),
          child: Stack(
            children: [
              if (isActive)
                Positioned.fill(
                  child: Container(
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
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              Center(
                child: TextButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 24),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    foregroundColor: WidgetStateProperty.all(
                      isActive ? Colors.white : const Color(0xFF222222),
                    ),
                    backgroundColor: WidgetStateProperty.all(
                        isActive ? Colors.transparent : Colors.white),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  onPressed: _handlePress,
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF222222),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
