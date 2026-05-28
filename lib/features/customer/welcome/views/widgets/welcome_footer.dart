import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_inline_text_link.dart';

class WelcomeFooter extends StatelessWidget {
  const WelcomeFooter({required this.onLogin, super.key});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          'Đã có tài khoản?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.60),
            fontSize: 14,
            height: 1.42,
          ),
        ),
        AppInlineTextLink(label: 'Đăng nhập', onTap: onLogin),
      ],
    );
  }
}
