import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../data/models/order_detail_model.dart';

class OrderHeaderCard extends StatelessWidget {
  const OrderHeaderCard({required this.order, super.key});

  final OrderDetailModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.orderAccent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.orderAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đơn hàng #${order.orderId}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Bàn ${order.tableNumber}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(label: _statusLabel(order.status)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _InfoChip(
                icon: Icons.schedule_rounded,
                label: _statusLabel(order.status),
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.payments_rounded,
                label: _paymentLabel(order.paymentStatus),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    return switch (status) {
      'PENDING' => 'Đang xử lý',
      'PREPARING' => 'Đang nấu',
      'READY' => 'Sẵn sàng',
      'SERVED' => 'Đã phục vụ',
      'COMPLETED' => 'Hoàn tất',
      'CANCELLED' => 'Đã hủy',
      _ => status,
    };
  }

  static String _paymentLabel(String status) {
    return switch (status) {
      'UNPAID' => 'Chưa thanh toán',
      'PAID' => 'Đã thanh toán',
      'PENDING' => 'Chờ thanh toán',
      _ => status,
    };
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.menuAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.menuAccent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F2F3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.orderAccent, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
