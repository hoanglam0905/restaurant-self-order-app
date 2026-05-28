import 'package:flutter/material.dart';

class AppAuthTextField extends StatelessWidget {
  const AppAuthTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.height = 56,
    this.borderRadius = 12,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          color: Color(0xFF161C23),
          fontSize: 16,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF5D5E61),
            fontSize: 16,
            height: 1.5,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: contentPadding,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Color(0xFFE0BFB7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Color(0xFFA73413), width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Color(0xFFCC2B00)),
          ),
        ),
      ),
    );
  }
}
