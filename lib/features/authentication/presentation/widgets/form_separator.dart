import 'package:flutter/material.dart';

class FormSeparator extends StatelessWidget {
  final double verticalSpacing;

  const FormSeparator({this.verticalSpacing = 8.0, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalSpacing),
      child: Container(
        width: double.infinity,
        height: 1,
        color: const Color(0xFFDBDFE4),
      ),
    );
  }
}
