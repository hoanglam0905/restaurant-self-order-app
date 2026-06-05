import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_inline_text_link.dart';
import '../../../../../core/widgets/app_state_panel.dart';
import '../../controllers/customer_notification_controller.dart';
import '../../data/models/customer_notification_model.dart';

class CustomerNotificationSheet extends StatelessWidget {
  const CustomerNotificationSheet({required this.controller, super.key});

  final CustomerNotificationController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1D9D6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Thông báo',
                      style: TextStyle(
                        color: Color(0xFF252429),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),
                  Obx(
                    () => controller.notifications.isEmpty
                        ? const SizedBox.shrink()
                        : AppInlineTextLink(
                            label: 'Xóa tất cả',
                            onTap: controller.clearAll,
                            textColor: AppColors.orderAccent,
                            fontSize: 13,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: Obx(() {
                  final notifications = controller.notifications;
                  if (notifications.isEmpty) {
                    return const AppStatePanel(
                      message:
                          'Chưa có thông báo mới về trạng thái đơn hàng hoặc món ăn.',
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _CustomerNotificationTile(
                        notification: notifications[index],
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerNotificationTile extends StatelessWidget {
  const _CustomerNotificationTile({required this.notification});

  final CustomerNotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final icon = switch (notification.kind) {
      CustomerNotificationKind.orderItem => Icons.restaurant_rounded,
      CustomerNotificationKind.payment => Icons.payments_rounded,
      CustomerNotificationKind.order => Icons.receipt_long_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : AppColors.orderAccent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notification.isRead
              ? const Color(0xFFECE5E3)
              : AppColors.orderAccent.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.orderAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.orderAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF252429),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.orderAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    color: Color(0xFF686267),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.34,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  notification.timeLabel,
                  style: const TextStyle(
                    color: Color(0xFF9B9498),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
