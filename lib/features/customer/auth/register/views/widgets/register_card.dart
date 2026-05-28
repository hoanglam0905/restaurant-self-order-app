import 'package:flutter/material.dart';

import '../../../../../../core/widgets/app_auth_social_options.dart';
import '../../../../../../core/widgets/app_inline_text_link.dart';
import '../../controllers/register_controller.dart';
import 'register_form.dart';

class RegisterCard extends StatelessWidget {
  const RegisterCard({
    required this.controller,
    required this.onSubmit,
    required this.onGoogle,
    required this.onFacebook,
    required this.onLogin,
    super.key,
  });

  final RegisterController controller;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final VoidCallback onFacebook;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 17, 28, 17),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0BFB7)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RegisterCardHeader(),
          const SizedBox(height: 32),
          RegisterForm(controller: controller, onSubmit: onSubmit),
          const SizedBox(height: 32),
          AppAuthSocialOptions(
            dividerLabel: 'HOẶC ĐĂNG KÝ VỚI',
            onGoogle: onGoogle,
            onFacebook: onFacebook,
          ),
          const SizedBox(height: 32),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                const Text(
                  'Đã có tài khoản?',
                  style: TextStyle(
                    color: Color(0xFF5D5E61),
                    fontSize: 14,
                    height: 1.42,
                  ),
                ),
                AppInlineTextLink(
                  label: 'Đăng nhập',
                  onTap: onLogin,
                  textColor: const Color(0xFFA73413),
                  fontSize: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterCardHeader extends StatelessWidget {
  const _RegisterCardHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tạo tài khoản',
          style: TextStyle(
            color: Color(0xFF161C23),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFA73413),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
