import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppActionTile extends StatelessWidget {
  const AppActionTile({
    required this.imagePath,
    required this.label,
    required this.onTap,
    this.width = 68,
    this.height = 68,
    this.imageWidth = 57,
    this.imageHeight = 55,
    super.key,
  });

  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double imageWidth;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: width,
              height: height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                imagePath,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
