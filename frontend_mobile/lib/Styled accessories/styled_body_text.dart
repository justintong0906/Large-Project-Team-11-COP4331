import 'package:flutter/material.dart';

class StyledBodyText extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? textAlign;

  const StyledBodyText(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 16.0,
    required this.fontWeight, // <--- Now Required
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        // Use the provided color, or fall back to a dark grey if null
        color: color ?? Colors.white,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
