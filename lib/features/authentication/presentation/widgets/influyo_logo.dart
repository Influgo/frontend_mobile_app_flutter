import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfluyoLogo extends StatelessWidget {
  final double logoHeight;

  const InfluyoLogo({
    super.key,
    this.logoHeight = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        SvgPicture.asset(
          'assets/images/influyo_logo.svg',
          height: logoHeight,
        ),
        const Spacer(),
      ],
    );
  }
}
