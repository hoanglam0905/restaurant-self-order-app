import 'package:flutter/material.dart';

class AppPasswordVisibilityButton extends StatelessWidget {
  const AppPasswordVisibilityButton({
    required this.obscureText,
    required this.onPressed,
    super.key,
  });

  final bool obscureText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: const Color(0xFF5D5E61),
      ),
    );
  }
}
