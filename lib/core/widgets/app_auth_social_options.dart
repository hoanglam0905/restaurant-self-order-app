import 'package:flutter/material.dart';

import 'app_labeled_divider.dart';
import 'app_outlined_icon_button.dart';

class AppAuthSocialOptions extends StatelessWidget {
  const AppAuthSocialOptions({
    required this.dividerLabel,
    required this.onGoogle,
    required this.onFacebook,
    super.key,
  });

  final String dividerLabel;
  final VoidCallback onGoogle;
  final VoidCallback onFacebook;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppLabeledDivider(
          label: dividerLabel,
          lineColor: const Color(0xFFE0BFB7),
          labelColor: const Color(0xFF5D5E61),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: AppOutlinedIconButton(
                onPressed: onGoogle,
                icon: const _GoogleMark(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppOutlinedIconButton(
                onPressed: onFacebook,
                icon: const _FacebookMark(),
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
        fontSize: 28,
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
