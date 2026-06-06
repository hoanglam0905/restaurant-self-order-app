import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../order/data/models/order_detail_model.dart';

class CustomerReservationHistoryCard extends StatelessWidget {
  const CustomerReservationHistoryCard({required this.order, super.key});

  final OrderDetailModel order;

  @override
  Widget build(BuildContext context) {
    final date = order.reservationTime;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDE4E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: AppColors.orderAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bàn ${order.tableNumber.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      date == null
                          ? 'Chưa có thời gian'
                          : _formatDateTime(date),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _ReservationStatusPill(status: order.status),
            ],
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0E5E2)),
            const SizedBox(height: 10),
            ...order.items.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.dishName?.trim().isNotEmpty == true
                            ? item.dishName!.trim()
                            : 'Món #${item.dishId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (order.items.length > 3)
              Text(
                '+${order.items.length - 3} món khác',
                style: const TextStyle(
                  color: AppColors.orderAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ReservationStatusPill extends StatelessWidget {
  const _ReservationStatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final label = switch (normalized) {
      'SCHEDULED' => 'Chờ duyệt',
      'PENDING' => 'Đã duyệt',
      'PROCESSING' => 'Đã nhận',
      'COMPLETED' => 'Hoàn tất',
      'CANCELLED' || 'CANCELED' => 'Đã hủy',
      _ => status,
    };
    final color = switch (normalized) {
      'SCHEDULED' => const Color(0xFFC98100),
      'CANCELLED' || 'CANCELED' => const Color(0xFFC62828),
      'COMPLETED' => const Color(0xFF2E7D32),
      _ => AppColors.orderAccent,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/'
      '${value.year} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}
