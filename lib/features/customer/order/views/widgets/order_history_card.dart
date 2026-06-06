import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/app_price_formatter.dart';
import '../../data/models/order_detail_model.dart';

class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({
    required this.order,
    required this.onViewDetail,
    required this.onPrint,
    super.key,
  });

  final OrderDetailModel order;
  final VoidCallback onViewDetail;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
            child: Row(
              children: [
                _TableBadge(tableNumber: order.tableNumber),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã HF : #${order.orderId.toString().padLeft(4, '0')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF333236),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF9A9699),
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _dateTimeText(
                              order.orderDate ?? order.reservationTime,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF9A9699),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _PaymentBadge(status: order.paymentStatus),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0E0DE)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TỔNG CỘNG',
                        style: TextStyle(
                          color: Color(0xFF9A7B72),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (order.hasDiscount) ...[
                        _AmountLine(
                          label: 'Giá gốc',
                          value: formatAppPrice(
                            order.totalAmount,
                            withCurrency: true,
                          ),
                        ),
                        const SizedBox(height: 3),
                        _AmountLine(
                          label: 'Giảm giá',
                          value:
                              '-${formatAppPrice(order.discount, withCurrency: true)}',
                          valueColor: const Color(0xFF3F8E3D),
                        ),
                        const SizedBox(height: 5),
                      ],
                      Text(
                        formatAppPrice(order.finalAmount, withCurrency: true),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.orderAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                _CirclePrintButton(onTap: onPrint),
                const SizedBox(width: 12),
                _DetailButton(onTap: onViewDetail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dateTimeText(DateTime? dateTime) {
    final date = dateTime ?? DateTime.now();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:00';
  }
}

class _TableBadge extends StatelessWidget {
  const _TableBadge({required this.tableNumber});

  final int tableNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F3),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'BÀN',
              style: TextStyle(
                color: Color(0xFFC97B68),
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'T-${tableNumber.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: AppColors.orderAccent,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final paid = status == 'PAID';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: paid ? const Color(0xFFEFF9EF) : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        paid ? 'ĐÃ THANH TOÁN' : 'CHƯA THANH TOÁN',
        style: TextStyle(
          color: paid ? const Color(0xFF4C9A4A) : const Color(0xFFC47B1B),
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AmountLine extends StatelessWidget {
  const _AmountLine({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF686267),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8E888B),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _CirclePrintButton extends StatelessWidget {
  const _CirclePrintButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEBCBC2)),
          ),
          child: const Icon(
            Icons.print_outlined,
            color: Color(0xFF6D6868),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _DetailButton extends StatelessWidget {
  const _DetailButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          width: 109,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.orderAccent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Text(
              'Xem chi tiết',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
