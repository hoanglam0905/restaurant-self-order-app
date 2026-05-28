import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_cta_button.dart';
import '../../../../../core/widgets/app_labeled_divider.dart';
import '../../../../../core/widgets/app_social_sign_in_button.dart';

class WelcomeActionSection extends StatelessWidget {
  const WelcomeActionSection({
    required this.onQrScan,
    required this.onRegister,
    required this.onGoogle,
    required this.onFacebook,
    super.key,
  });

  final VoidCallback onQrScan;
  final VoidCallback onRegister;
  final VoidCallback onGoogle;
  final VoidCallback onFacebook;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCtaButton(
          label: 'Quét mã QR ngay!',
          onPressed: onQrScan,
          backgroundColor: const Color(0xFFCC2B00),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              offset: const Offset(0, 10),
              blurRadius: 15,
              spreadRadius: -3,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: AppCtaButton(
              label: 'Đăng ký',
              onPressed: onRegister,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const AppLabeledDivider(label: 'HOẶC KẾT NỐI QUA'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppSocialSignInButton(
                label: 'Google',
                icon: const _GoogleMark(),
                onPressed: onGoogle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppSocialSignInButton(
                label: 'Facebook',
                icon: const _FacebookMark(),
                onPressed: onFacebook,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 22,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }
}

class _FacebookMark extends StatelessWidget {
  const _FacebookMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: const Text(
        'f',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
