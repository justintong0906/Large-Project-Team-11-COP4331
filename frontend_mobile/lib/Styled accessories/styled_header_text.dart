import 'package:flutter/material.dart';

class StyledHeaderText extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? textAlign;

  const StyledHeaderText(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 32.0, // Default size for headers
    this.fontWeight = FontWeight.bold, // Default weight for headers
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        // Use the provided color, or fall back to black if null
        color: color ?? Colors.white,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
