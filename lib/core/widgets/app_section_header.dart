import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.onTap,
    this.trailingIcon = Icons.chevron_right,
    super.key,
  });

  final String title;
  final VoidCallback? onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F1F1),
            shape: BoxShape.circle,
          ),
          child: Icon(trailingIcon, size: 18, color: AppColors.textPrimary),
        ),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: content,
    );
  }
}
