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
    this.fontSize = 16.0, // Default size for body text
    this.fontWeight = FontWeight.normal, // Default weight for body text
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        // Use the provided color, or fall back to a dark grey if null
        color: color ?? Colors.grey[800],
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}