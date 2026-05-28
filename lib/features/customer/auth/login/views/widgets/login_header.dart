import 'package:flutter/material.dart';

import '../../../../../../core/widgets/app_back_icon_button.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AppBackIconButton(onTap: onBack),
        ),
        const SizedBox(height: 70),
        Image.asset(
          'assets/images/auth/login_logo.png',
          width: 196,
          height: 106,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 48),
        const Text(
          'Chào mừng trở lại',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF161C23),
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Đăng nhập để sử dụng những tiện ích của nhà hàng nhé',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF5D5E61), fontSize: 14, height: 1.7),
        ),
      ],
    );
  }
}
