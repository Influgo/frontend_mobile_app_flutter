import 'package:flutter/material.dart';

class CustomCheckmarkSimple extends StatelessWidget {
  const CustomCheckmarkSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 139,
      height: 139,
      decoration: const BoxDecoration(
        color: Color(0xFFDBF2DD),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          // width: 80,
          // height: 80,
          // decoration: const BoxDecoration(
          //   color: Color(0xFF1B5E20),
          //   shape: BoxShape.circle,
          // ),
          child: Center(
            child: Image.asset(
              'assets/images/check.gif',
              width: 61,
              height: 61,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
