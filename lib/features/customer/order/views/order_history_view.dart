import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_customer_bottom_nav_bar.dart';
import '../../../../core/widgets/app_state_panel.dart';
import '../../menu/views/menu_view.dart';
import '../controllers/order_history_controller.dart';
import '../data/services/order_history_service.dart';
import 'order_detail_view.dart';
import 'widgets/order_history_card.dart';
import 'widgets/order_history_section_label.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  late final String _controllerTag;
  late final OrderHistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = UniqueKey().toString();
    _controller = Get.put(
      OrderHistoryController(
        orderHistoryService: OrderHistoryService(ApiClient()),
      ),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    Get.delete<OrderHistoryController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.menuSurface,
      body: SafeArea(
        child: Column(
          children: [
            const _HistoryTopBar(),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value && _controller.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.errorMessage.value.isNotEmpty &&
                    _controller.orders.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: AppStatePanel(
                      message: _controller.errorMessage.value,
                      actionLabel: 'Thử lại',
                      onAction: _controller.loadHistory,
                    ),
                  );
                }

                if (_controller.orders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: AppStatePanel(message: 'Bạn chưa có đơn hàng nào.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _controller.loadHistory,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
                    children: [
                      const _HistoryTitleBlock(),
                      const SizedBox(height: 28),
                      ..._buildSections(context),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppCustomerBottomNavBar(
        currentIndex: 3,
        onItemSelected: (index) => _onNavSelected(context, index),
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context) {
    final widgets = <Widget>[];
    final groups = _controller.groupedOrders;

    groups.forEach((label, orders) {
      widgets.add(OrderHistorySectionLabel(label: label));
      widgets.add(const SizedBox(height: 18));
      for (final order in orders) {
        widgets.add(
          OrderHistoryCard(
            order: order,
            onPrint: () => _showPending(context),
            onViewDetail: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailView(orderId: order.orderId),
                ),
              );
            },
          ),
        );
        widgets.add(const SizedBox(height: 16));
      }
      widgets.add(const SizedBox(height: 18));
    });

    return widgets;
  }

  void _onNavSelected(BuildContext context, int index) {
    if (index == 3) {
      return;
    }

    if (index == 0) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuView.viewOnly()),
      );
      return;
    }

    _showPending(context);
  }

  void _showPending(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng này chưa được kết nối.')),
    );
  }
}

class _HistoryTopBar extends StatelessWidget {
  const _HistoryTopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 14, 0),
        child: Row(
          children: [
            const Icon(
              Icons.history_rounded,
              color: AppColors.orderAccent,
              size: 23,
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Lịch sử đơn hàng',
                style: TextStyle(
                  color: Color(0xFF333236),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF4C4B50),
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFF1E8E5),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.orderAccent,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTitleBlock extends StatelessWidget {
  const _HistoryTitleBlock();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QUẢN LÝ',
                style: TextStyle(
                  color: Color(0xFF8D888C),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Lịch sử Đơn hàng',
                style: TextStyle(
                  color: Color(0xFF252429),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EAF0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: AppColors.orderAccent,
                size: 15,
              ),
              SizedBox(width: 7),
              Text(
                'Hôm nay',
                style: TextStyle(
                  color: AppColors.orderAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
