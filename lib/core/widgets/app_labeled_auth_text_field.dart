import 'package:flutter/material.dart';

import 'app_auth_text_field.dart';

class AppLabeledAuthTextField extends StatelessWidget {
  const AppLabeledAuthTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF5D5E61),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 8),
        AppAuthTextField(
          controller: controller,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          height: 44,
          borderRadius: 8,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ],
    );
  }
}
