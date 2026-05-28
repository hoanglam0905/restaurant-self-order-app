import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppSurfaceCommandButton extends StatelessWidget {
  const AppSurfaceCommandButton({
    required this.label,
    required this.onTap,
    this.trailingAsset,
    this.trailingIcon,
    this.height = 68,
    this.backgroundColor = AppColors.surfaceMuted,
    this.labelColor = AppColors.textTertiary,
    this.fontSize = 18,
    this.borderRadius = 8,
    this.trailingWidth = 52,
    this.trailingHeight = 36,
    this.trailingRight = 36,
    this.trailingBottom = 7,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final String? trailingAsset;
  final IconData? trailingIcon;
  final double height;
  final Color backgroundColor;
  final Color labelColor;
  final double fontSize;
  final double borderRadius;
  final double trailingWidth;
  final double trailingHeight;
  final double trailingRight;
  final double trailingBottom;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            if (trailingAsset != null)
              Positioned(
                right: trailingRight,
                bottom: trailingBottom,
                child: Image.asset(
                  trailingAsset!,
                  width: trailingWidth,
                  height: trailingHeight,
                  fit: BoxFit.contain,
                ),
              ),
            if (trailingIcon != null)
              Positioned(
                right: trailingRight,
                child: Icon(trailingIcon, color: labelColor, size: 34),
              ),
          ],
        ),
      ),
    );
  }
}
