import 'package:flutter/material.dart';
import '../../data/models/staff_kitchen_order_model.dart';

class KitchenOrderCard extends StatelessWidget {
  const KitchenOrderCard({
    super.key,
    required this.order,
    required this.onStartPressed,
    required this.onCompletePressed,
  });

  final StaffKitchenOrderModel order;
  final VoidCallback onStartPressed;
  final VoidCallback onCompletePressed;

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(order.status.badgeColorValue);
    final isPending = order.status == KitchenOrderStatus.pending;
    final isInProgress = order.status == KitchenOrderStatus.inProgress;
    final isCompleted = order.status == KitchenOrderStatus.completed;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDF2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.tableNumber,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')} • ${order.totalItems} món',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            if (item.note != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  item.note!,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        'x${item.quantity}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF4B5563)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 4),
            if (order.alertText != null)
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFE4572E), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.alertText!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE4572E)),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCompleted ? null : (isPending ? onStartPressed : onCompletePressed),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPending ? const Color(0xFF9E3A14) : isInProgress ? const Color(0xFF2E7D32) : const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      isPending ? 'ĐANG LÀM' : isInProgress ? 'HOÀN TẤT' : 'ĐÃ HOÀN TẤT',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
