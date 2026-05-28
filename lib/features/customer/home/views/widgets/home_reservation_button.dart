import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_surface_command_button.dart';

class HomeReservationButton extends StatelessWidget {
  const HomeReservationButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCommandButton(
      label: 'Đặt bàn trải nghiệm',
      onTap: onTap,
      height: 56,
      fontSize: 15,
      trailingIcon: Icons.chevron_right_rounded,
      trailingRight: 72,
      backgroundColor: const Color(0xFFF9F4F6),
      labelColor: const Color(0xFF747474),
    );
  }
}
