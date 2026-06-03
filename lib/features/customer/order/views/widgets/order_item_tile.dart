import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/app_price_formatter.dart';
import '../../data/models/order_item_model.dart';
import 'order_status_text.dart';

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({
    required this.item,
    this.onCancel,
    this.isCancelling = false,
    super.key,
  });

  final OrderItemModel item;
  final VoidCallback? onCancel;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x1FE0BFB7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE3EC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.orderAccent,
              size: 28,
            ),
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
                        item.dishName ?? 'Món ăn #${item.dishId}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF161C23),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orderAccent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          color: AppColors.orderAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ghi chú: ${item.notes!.trim()}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF5D5E61),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _ItemStatusPill(
                        label: orderItemStatusLabel(item.status),
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatAppPrice(item.subtotal, withCurrency: true),
                      style: const TextStyle(
                        color: AppColors.orderAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                if (onCancel != null) ...[
                  const SizedBox(height: 10),
                  _CancelPendingItemAction(
                    isLoading: isCancelling,
                    onTap: onCancel!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status.toUpperCase()) {
      'PROCESSING' => const Color(0xFFC47B1B),
      'COMPLETED' => const Color(0xFF3F8E3D),
      'CANCELLED' => const Color(0xFFB3261E),
      _ => AppColors.orderAccent,
    };
  }
}

class _ItemStatusPill extends StatelessWidget {
  const _ItemStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CancelPendingItemAction extends StatelessWidget {
  const _CancelPendingItemAction({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isLoading ? null : onTap,
          child: Ink(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2F0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFCDC7)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(
                    Icons.close_rounded,
                    color: Color(0xFFB3261E),
                    size: 16,
                  ),
                const SizedBox(width: 6),
                Text(
                  isLoading ? 'Đang hủy...' : 'Hủy món',
                  style: const TextStyle(
                    color: Color(0xFFB3261E),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
