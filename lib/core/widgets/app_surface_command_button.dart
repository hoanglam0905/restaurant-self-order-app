import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppSurfaceCommandButton extends StatelessWidget {
  const AppSurfaceCommandButton({
    required this.label,
    required this.onTap,
    this.trailingAsset,
    this.height = 68,
    this.trailingWidth = 52,
    this.trailingHeight = 36,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final String? trailingAsset;
  final double height;
  final double trailingWidth;
  final double trailingHeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            if (trailingAsset != null)
              Positioned(
                right: 36,
                bottom: 7,
                child: Image.asset(
                  trailingAsset!,
                  width: trailingWidth,
                  height: trailingHeight,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
