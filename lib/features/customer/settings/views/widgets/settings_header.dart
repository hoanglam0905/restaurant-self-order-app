import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.settings_rounded, color: AppColors.orderAccent, size: 24),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Cài đặt',
            style: TextStyle(
              color: Color(0xFF252429),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFF1E8E5),
          child: Icon(
            Icons.person_rounded,
            color: AppColors.orderAccent,
            size: 20,
          ),
        ),
      ],
    );
  }
}
