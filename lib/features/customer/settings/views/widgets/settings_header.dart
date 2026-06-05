import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    required this.unreadCount,
    required this.onNotificationsTap,
    super.key,
  });

  final int unreadCount;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final badgeLabel = unreadCount > 99 ? '99+' : unreadCount.toString();

    return Row(
      children: [
        const Icon(
          Icons.settings_rounded,
          color: AppColors.orderAccent,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Cài đặt',
            style: TextStyle(
              color: Color(0xFF252429),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        Tooltip(
          message: 'Thông báo',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onNotificationsTap,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFF1E8E5),
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.orderAccent,
                        size: 20,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -6,
                        top: -5,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC0392B),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            badgeLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
