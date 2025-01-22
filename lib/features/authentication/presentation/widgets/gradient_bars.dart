import 'package:flutter/material.dart';

class GradientBars extends StatelessWidget {
  final int barCount;

  const GradientBars({
    super.key,
    required this.barCount,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> bars = [];

    for (int i = 0; i < barCount; i++) {
      bars.add(
        Expanded(
          child: Container(
            height: 4,
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
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
        ),
      );

      if (i < barCount - 1) {
        bars.add(const SizedBox(width: 8));
      }
    }

    if (barCount == 1) {
      bars.add(const SizedBox(width: 8));
      bars.add(
        Expanded(
          child: Container(
            height: 4,
            color: const Color(0xFFE0E0E0),
          ),
        ),
      );
      bars.add(const SizedBox(width: 8));
      bars.add(
        Expanded(
          child: Container(
            height: 4,
            color: const Color(0xFFE0E0E0),
          ),
        ),
      );
    } else if (barCount == 2) {
      bars.add(const SizedBox(width: 8));
      bars.add(
        Expanded(
          child: Container(
            height: 4,
            color: const Color(0xFFE0E0E0),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
      child: Row(
        children: bars,
      ),
    );
  }
}
