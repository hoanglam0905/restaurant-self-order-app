import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../chatbot/views/chatbot_view.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/home/logo_bon_appetit.png',
              width: 112,
              height: 28,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 6),
            const Text(
              '450 Le Van Viet Street, Tang Nhon Phu A Ward,\nDistrict 9',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDE8E4),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.welcomeAccent.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.welcomeAccent,
              size: 26,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotView()),
              );
            },
          ),
        ),
      ],
    );
  }
}

