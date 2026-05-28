import 'package:flutter/material.dart';

class AppInlineTextLink extends StatelessWidget {
  const AppInlineTextLink({
    required this.label,
    required this.onTap,
    this.textColor = Colors.white,
    this.fontSize = 14,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              height: 1.42,
            ),
          ),
        ),
      ),
    );
  }
}
