import 'package:flutter/material.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;

  const SectionTitleWidget(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
    );
  }
}
