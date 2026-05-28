import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class WelcomeBrandHeader extends StatelessWidget {
  const WelcomeBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'CHÀO MỪNG ĐẾN VỚI',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.80),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.6,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 16),
        Image.asset(
          'assets/images/welcome/welcome_logo.png',
          width: 192,
          height: 79,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.welcomeAccent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
