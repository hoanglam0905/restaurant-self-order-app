import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/home/logo_bon_appetit.png',
          width: 112,
          height: 28,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 6),
        const Text(
          '450 Le Van Viet Street, Tang Nhon Phu A Ward,\nDistrict 9',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
