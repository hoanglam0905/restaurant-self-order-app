import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    required this.width,
    required this.height,
    this.radius = 0,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
