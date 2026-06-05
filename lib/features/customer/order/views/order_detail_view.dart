import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_icon_button.dart';
import '../../../../core/widgets/app_cta_button.dart';
import '../../../../core/widgets/app_state_panel.dart';
import '../../../../core/widgets/app_surface_command_button.dart';
import '../../feedback/views/customer_feedback_view.dart';
import '../../home/views/home_view.dart';
import '../controllers/order_detail_controller.dart';
import '../data/models/order_detail_model.dart';
import '../data/models/order_item_model.dart';
import '../data/services/order_detail_service.dart';
import '../data/services/order_receipt_service.dart';
import 'order_payment_view.dart';
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
    final apiClient = ApiClient();
    _controller = Get.put(
      OrderDetailController(
        orderDetailService: OrderDetailService(apiClient),
        orderReceiptService: OrderReceiptService(apiClient),
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
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        child: Column(
          children: [
            _OrderTopBar(onBack: () => Navigator.pop(context)),
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
                  cancellingDishId: _controller.cancellingDishId.value,
                  isExportingReceipt: _controller.isExportingReceipt.value,
                  onRefresh: _controller.loadOrder,
                  onHome: () => _goHome(context),
                  onPrint: () => _exportReceipt(context),
                  onEvaluate: () => _openFeedback(context, order),
                  onCancelItem: (item) => _cancelPendingItem(context, item),
                  canCancelItem: _controller.canCancelItem,
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        final order = _controller.order.value;
        if (order == null || order.paymentStatus.toUpperCase() == 'PAID') {
          return const SizedBox.shrink();
        }

        return _UnpaidBottomAction(
          loading: _controller.isProcessingPayment.value,
          onPay: () => _openPaymentView(context, order),
        );
      }),
    );
  }

  Future<void> _openPaymentView(
    BuildContext context,
    OrderDetailModel order,
  ) async {
    final paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OrderPaymentView(order: order, controller: _controller),
      ),
    );

    if (paid == true) {
      await _controller.loadOrder();
    }
  }

  Future<void> _openFeedback(
    BuildContext context,
    OrderDetailModel order,
  ) async {
    await _controller.refreshLoyaltyBalance();
    if (!context.mounted) {
      return;
    }

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerFeedbackView(
          orderId: order.orderId,
          earnedPoints: _controller.estimatedEarnedPointsFor(order),
        ),
      ),
    );
  }

  Future<void> _cancelPendingItem(
    BuildContext context,
    OrderItemModel item,
  ) async {
    final success = await _controller.cancelPendingItem(item);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã hủy món đang chờ xử lý.'
              : _controller.errorMessage.value,
        ),
        backgroundColor: AppColors.orderAccent,
      ),
    );
  }

  Future<void> _exportReceipt(BuildContext context) async {
    final filePath = await _controller.exportReceiptPdf();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          filePath == null
              ? _controller.receiptMessage.value
              : 'Đã xuất hóa đơn PDF.',
        ),
        backgroundColor: AppColors.orderAccent,
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeView()),
      (_) => false,
    );
  }
}

class _OrderTopBar extends StatelessWidget {
  const _OrderTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xCCF7F9FF),
        border: Border(bottom: BorderSide(color: Color(0xFFE0BFB7))),
      ),
      child: Row(
        children: [
          AppBackIconButton(onTap: onBack),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFEFE8E6)),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppColors.orderAccent,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Bon Appétit',
                style: TextStyle(
                  color: AppColors.orderAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 50),
        ],
      ),
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  const _OrderDetailContent({
    required this.order,
    required this.cancellingDishId,
    required this.isExportingReceipt,
    required this.onRefresh,
    required this.onHome,
    required this.onPrint,
    required this.onEvaluate,
    required this.onCancelItem,
    required this.canCancelItem,
  });

  final OrderDetailModel order;
  final int cancellingDishId;
  final bool isExportingReceipt;
  final Future<void> Function() onRefresh;
  final VoidCallback onHome;
  final VoidCallback onPrint;
  final VoidCallback onEvaluate;
  final ValueChanged<OrderItemModel> onCancelItem;
  final bool Function(OrderItemModel item) canCancelItem;

  @override
  Widget build(BuildContext context) {
    final paid = order.paymentStatus.toUpperCase() == 'PAID';

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(12, 14, 12, paid ? 24 : 96),
        children: [
          OrderHeaderCard(order: order),
          const SizedBox(height: 14),
          if (!paid) ...[
            OrderProgressPanel(status: order.status),
            const SizedBox(height: 14),
          ],
          _SectionHeading(count: order.items.length),
          const SizedBox(height: 12),
          if (order.items.isEmpty)
            const AppStatePanel(message: 'Đơn hàng chưa có món.')
          else
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: OrderItemTile(
                  item: item,
                  isCancelling: cancellingDishId == item.dishId,
                  onCancel: canCancelItem(item)
                      ? () => onCancelItem(item)
                      : null,
                ),
              ),
            ),
          const SizedBox(height: 8),
          OrderTotalPanel(order: order),
          const SizedBox(height: 20),
          if (paid)
            _PaidActions(
              onHome: onHome,
              onPrint: onPrint,
              onEvaluate: onEvaluate,
              isExportingReceipt: isExportingReceipt,
            ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.list_alt_rounded,
          color: AppColors.orderAccent,
          size: 19,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Chi tiết món ăn',
            style: TextStyle(
              color: Color(0xFF161C23),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '$count món',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PaidActions extends StatelessWidget {
  const _PaidActions({
    required this.onHome,
    required this.onPrint,
    required this.onEvaluate,
    required this.isExportingReceipt,
  });

  final VoidCallback onHome;
  final VoidCallback onPrint;
  final VoidCallback onEvaluate;
  final bool isExportingReceipt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCtaButton(
          label: 'Đánh giá nhà hàng',
          onPressed: onEvaluate,
          backgroundColor: Colors.black,
          borderRadius: 8,
          fontSize: 15,
          height: 56,
          trailing: const Icon(
            Icons.star_rounded,
            color: Color(0xFFFFC43B),
            size: 22,
          ),
        ),
        const SizedBox(height: 12),
        AppCtaButton(
          label: 'Về trang chủ',
          onPressed: onHome,
          backgroundColor: const Color(0xFFB24D30),
          borderRadius: 8,
          fontSize: 15,
          height: 56,
          trailing: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 16),
        AppSurfaceCommandButton(
          label: isExportingReceipt ? 'Đang xuất PDF...' : 'In PDF',
          onTap: isExportingReceipt ? () {} : onPrint,
          height: 56,
          backgroundColor: const Color(0xFFDDE3EC),
          labelColor: AppColors.orderAccent,
          fontSize: 15,
          borderRadius: 8,
          trailingIcon: Icons.receipt_long_outlined,
          trailingRight: 104,
        ),
      ],
    );
  }
}

class _UnpaidBottomAction extends StatelessWidget {
  const _UnpaidBottomAction({required this.loading, required this.onPay});

  final bool loading;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0DADA))),
      ),
      child: SafeArea(
        top: false,
        child: AppSurfaceCommandButton(
          label: loading ? 'Đang thanh toán...' : 'Thanh toán',
          onTap: loading ? () {} : onPay,
          height: 52,
          backgroundColor: const Color(0xFFDDE3EC),
          labelColor: AppColors.orderAccent,
          fontSize: 15,
          borderRadius: 8,
          trailingIcon: Icons.receipt_long_outlined,
          trailingRight: 100,
        ),
      ),
    );
  }
}
