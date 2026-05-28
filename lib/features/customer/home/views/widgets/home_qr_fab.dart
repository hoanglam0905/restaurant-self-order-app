import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class HomeQrFab extends StatelessWidget {
  const HomeQrFab({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'home_qr_fab',
      onPressed: onTap,
      backgroundColor: AppColors.welcomeAccent,
      elevation: 8,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.qr_code_scanner_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
