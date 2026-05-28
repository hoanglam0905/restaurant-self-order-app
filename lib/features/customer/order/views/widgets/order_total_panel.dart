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
      ),
      child: Column(
        children: [
          _TotalRow(
            label: 'Tạm tính',
            value: formatAppPrice(order.totalAmount, withCurrency: true),
          ),
          const SizedBox(height: 10),
          const _TotalRow(label: 'Phí dịch vụ', value: '0đ'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE5DFDF)),
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
      children: [
        Text(
          label,
          style: TextStyle(
            color: emphasized ? Colors.black : AppColors.textSecondary,
            fontSize: emphasized ? 15 : 13,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: emphasized ? AppColors.orderAccent : Colors.black,
            fontSize: emphasized ? 17 : 13,
            fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
