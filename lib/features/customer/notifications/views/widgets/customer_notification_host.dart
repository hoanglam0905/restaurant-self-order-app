import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../controllers/customer_notification_controller.dart';
import '../../data/models/customer_notification_model.dart';

class CustomerNotificationHost extends StatelessWidget {
  const CustomerNotificationHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = CustomerNotificationController.ensureRegistered();

    return Stack(
      children: [
        child,
        Obx(() {
          final notification = controller.activeNotification.value;
          return Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 14,
            right: 14,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.18),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: notification == null
                  ? const SizedBox.shrink(key: ValueKey('empty-notification'))
                  : Dismissible(
                      key: ValueKey(notification.id),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (_) =>
                          controller.dismissActiveNotification(),
                      child: _CustomerNotificationPopup(
                        notification: notification,
                      ),
                    ),
            ),
          );
        }),
      ],
    );
  }
}

class _CustomerNotificationPopup extends StatelessWidget {
  const _CustomerNotificationPopup({required this.notification});

  final CustomerNotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final icon = switch (notification.kind) {
      CustomerNotificationKind.orderItem => Icons.restaurant_rounded,
      CustomerNotificationKind.payment => Icons.payments_rounded,
      CustomerNotificationKind.order => Icons.receipt_long_rounded,
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFECE5E3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.orderAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.orderAccent, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF252429),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF686267),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.swipe_right_alt_rounded,
              color: Color(0xFFB8B1B4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
