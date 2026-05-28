import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kitchen_controller.dart';
import 'widgets/kitchen_order_card.dart';

class KitchenManagementView extends StatelessWidget {
  const KitchenManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KitchenController>();
    const primaryColor = Color(0xFF9E3A14);
    const scaffoldBg = Color(0xFFFCFCFC);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Màn hình Bếp',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Sắp xếp theo thời gian (cũ nhất trước)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Bộ lọc thời gian đang được phát triển.',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.access_time_rounded, size: 18),
                    label: const Text('Thời gian'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFDFE3E8)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => _buildStatusFilter(
                      selected: controller.selectedStatus.value,
                      onTap: () => _showStatusPicker(context, controller),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showSearchDialog(context, controller),
                    icon: const Icon(
                      Icons.search_rounded,
                      size: 24,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.orders.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }
                  if (controller.errorMessage.value.isNotEmpty &&
                      controller.orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: controller.loadOrders,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }
                  final filtered = controller.filteredOrders;
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không có đơn nào phù hợp.',
                        style: TextStyle(fontSize: 15, color: Colors.black45),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: primaryColor,
                    onRefresh: controller.loadOrders,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24, top: 4),
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final order = filtered[index];
                        return KitchenOrderCard(
                          order: order,
                          onStartPressed: () => controller.startOrder(order),
                          onCompletePressed: () =>
                              controller.completeOrder(order),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter({
    required String selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD1D8E3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.filter_alt_rounded,
              size: 18,
              color: Color(0xFF4B5563),
            ),
            const SizedBox(width: 8),
            Text(
              selected,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF334155),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, KitchenController controller) {
    final textController = TextEditingController(
      text: controller.searchQuery.value,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Tìm kiếm đơn',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nhập số bàn hoặc tên món',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.updateSearchQuery(textController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Tìm'),
            ),
          ],
        );
      },
    );
  }

  void _showStatusPicker(BuildContext context, KitchenController controller) {
    final options = ['Tất cả', 'Chưa làm', 'Đang làm', 'Hoàn tất'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Lọc trạng thái đơn',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ...options.map(
                (status) => ListTile(
                  title: Text(
                    status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: controller.selectedStatus.value == status
                      ? const Icon(Icons.check, color: Color(0xFF9E3A14))
                      : null,
                  onTap: () {
                    controller.changeStatusFilter(status);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
