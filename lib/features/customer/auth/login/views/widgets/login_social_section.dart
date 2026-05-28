import 'package:flutter/material.dart';

import '../../../../../../core/widgets/app_auth_social_options.dart';

class LoginSocialSection extends StatelessWidget {
  const LoginSocialSection({
    required this.onGoogle,
    required this.onFacebook,
    super.key,
  });

  final VoidCallback onGoogle;
  final VoidCallback onFacebook;

  @override
  Widget build(BuildContext context) {
    return AppAuthSocialOptions(
      dividerLabel: 'HOẶC ĐĂNG NHẬP VỚI',
      onGoogle: onGoogle,
      onFacebook: onFacebook,
    );
  }
}
