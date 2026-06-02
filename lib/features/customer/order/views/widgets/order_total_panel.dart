import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/app_price_formatter.dart';
import '../../data/models/order_detail_model.dart';

class OrderTotalPanel extends StatelessWidget {
  const OrderTotalPanel({required this.order, super.key});

  final OrderDetailModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x33E0BFB7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _SummaryMeta(
                  icon: Icons.table_restaurant_outlined,
                  label:
                      'Vị trí: Bàn ${order.tableNumber.toString().padLeft(2, '0')}',
                ),
                const SizedBox(width: 14),
                _SummaryMeta(
                  icon: Icons.fingerprint_rounded,
                  label:
                      'Mã đơn: #BA-${order.orderId.toString().padLeft(4, '0')}',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x1FE0BFB7)),
          const SizedBox(height: 12),
          _TotalRow(
            label: 'Tạm tính',
            value: formatAppPrice(order.totalAmount, withCurrency: true),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0x66E0BFB7), thickness: 1),
          ),
          _TotalRow(
            label: 'Tổng cộng',
            value: formatAppPrice(order.totalAmount, withCurrency: true),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryMeta extends StatelessWidget {
  const _SummaryMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5D5E61), size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF161C23),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? Colors.black : AppColors.textSecondary,
              fontSize: emphasized ? 18 : 14,
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          value,
          style: TextStyle(
            color: emphasized ? AppColors.orderAccent : AppColors.textSecondary,
            fontSize: emphasized ? 26 : 14,
            fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
