import 'package:flutter/material.dart';

class AppBackIconButton extends StatelessWidget {
  const AppBackIconButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: const SizedBox(
          width: 50,
          height: 30,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF5D5E61),
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
