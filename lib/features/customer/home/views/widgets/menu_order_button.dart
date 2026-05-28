import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_surface_command_button.dart';

class MenuOrderButton extends StatelessWidget {
  const MenuOrderButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCommandButton(
      label: 'View menu - Orders',
      onTap: onTap,
      trailingAsset: 'assets/images/home/call_bell.png',
      height: 48,
      fontSize: 15,
      trailingWidth: 42,
      trailingHeight: 30,
      trailingRight: 54,
      trailingBottom: 8,
    );
  }
}
