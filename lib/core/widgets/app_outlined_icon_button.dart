import 'package:flutter/material.dart';

class AppOutlinedIconButton extends StatelessWidget {
  const AppOutlinedIconButton({
    required this.icon,
    required this.onPressed,
    this.height = 56,
    super.key,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0BFB7)),
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
