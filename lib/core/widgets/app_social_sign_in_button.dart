import 'dart:ui';

import 'package:flutter/material.dart';

class AppSocialSignInButton extends StatelessWidget {
  const AppSocialSignInButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.height = 54,
    super.key,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: Colors.white.withValues(alpha: 0.10),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 24, height: 24, child: Center(child: icon)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.42,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
