import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_state_panel.dart';
import '../controllers/order_detail_controller.dart';
import '../data/models/order_detail_model.dart';
import '../data/services/order_detail_service.dart';
import 'widgets/order_header_card.dart';
import 'widgets/order_item_tile.dart';
import 'widgets/order_progress_panel.dart';
import 'widgets/order_total_panel.dart';

class OrderDetailView extends StatefulWidget {
  const OrderDetailView({required this.orderId, super.key});

  final int orderId;

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  late final String _controllerTag;
  late final OrderDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'order-detail-${widget.orderId}-${UniqueKey()}';
    _controller = Get.put(
      OrderDetailController(
        orderDetailService: OrderDetailService(ApiClient()),
        orderId: widget.orderId,
      ),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    Get.delete<OrderDetailController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.menuSurface,
      body: SafeArea(
        child: Column(
          children: [
            _OrderTopBar(onBack: () => Navigator.pop(context)),
            const Divider(height: 1, color: Color(0xFFE0D9D9)),
            Expanded(
              child: Obx(() {
                final order = _controller.order.value;
                if (_controller.isLoading.value && order == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.errorMessage.value.isNotEmpty &&
                    order == null) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppStatePanel(
                      message: _controller.errorMessage.value,
                      actionLabel: 'Thử lại',
                      onAction: _controller.loadOrder,
                    ),
                  );
                }

                if (order == null) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: AppStatePanel(message: 'Không tìm thấy đơn hàng.'),
                  );
                }

                return _OrderDetailContent(
                  order: order,
                  onRefresh: _controller.loadOrder,
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        final order = _controller.order.value;
        if (order == null) {
          return const SizedBox.shrink();
        }
        return _OrderBottomActions(order: order);
      }),
    );
  }
}

class _OrderTopBar extends StatelessWidget {
  const _OrderTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: onBack,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202020),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ),
          ),
          const Text(
            'View Order',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  const _OrderDetailContent({required this.order, required this.onRefresh});

  final OrderDetailModel order;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
        children: [
          OrderHeaderCard(order: order),
          const SizedBox(height: 12),
          OrderProgressPanel(status: order.status),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Món đã gọi',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '(${order.items.length} món)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (order.items.isEmpty)
            const AppStatePanel(message: 'Đơn hàng chưa có món.')
          else
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OrderItemTile(item: item),
              ),
            ),
          const SizedBox(height: 6),
          OrderTotalPanel(order: order),
        ],
      ),
    );
  }
}

class _OrderBottomActions extends StatelessWidget {
  const _OrderBottomActions({required this.order});

  final OrderDetailModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0DADA))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _BottomActionButton(
                label: 'Gọi nhân viên',
                icon: Icons.support_agent_rounded,
                backgroundColor: const Color(0xFFF3EFF0),
                foregroundColor: AppColors.orderAccent,
                onTap: () => _showPending(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BottomActionButton(
                label: order.paymentStatus == 'PAID'
                    ? 'Đã thanh toán'
                    : 'Thanh toán',
                icon: Icons.payments_rounded,
                backgroundColor: AppColors.orderAccent,
                foregroundColor: Colors.white,
                onTap: order.paymentStatus == 'PAID'
                    ? null
                    : () => _showPending(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPending(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng này chưa được kết nối.')),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          height: 46,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Opacity(
            opacity: onTap == null ? 0.65 : 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foregroundColor, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
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
