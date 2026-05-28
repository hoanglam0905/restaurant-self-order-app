import 'package:flutter/material.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/auth/login_logo.png',
      width: 196,
      height: 106,
      fit: BoxFit.contain,
    );
  }
}
