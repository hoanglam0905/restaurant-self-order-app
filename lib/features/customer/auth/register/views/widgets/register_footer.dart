import 'package:flutter/material.dart';

class RegisterFooter extends StatelessWidget {
  const RegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '© 2024 Bonappétit Direct. All rights\nreserved.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: const Color(0xFF8C716A).withValues(alpha: 0.60),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        height: 1.33,
      ),
    );
  }
}
