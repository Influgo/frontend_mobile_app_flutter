import 'package:flutter/material.dart';

class InfluyoLogo extends StatelessWidget {
  final double logoHeight;

  const InfluyoLogo({
    super.key,
    this.logoHeight = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          const Spacer(),
          Image.asset(
            'assets/images/influyo_logo.png',
            height: logoHeight,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}