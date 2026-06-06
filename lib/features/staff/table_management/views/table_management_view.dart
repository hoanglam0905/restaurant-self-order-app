import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../dish_management/data/models/staff_kitchen_order_item_model.dart';
import '../../dish_management/data/models/staff_kitchen_order_model.dart';
import '../controllers/table_controller.dart';
import '../data/models/staff_table_model.dart';
import '../data/models/table_notification_model.dart';
import '../data/models/table_status.dart';
import 'order_reservation_view.dart';
import 'widgets/table_card.dart';

class TableManagementView extends StatelessWidget {
  const TableManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TableController>();

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
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Quản lý bàn',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showSearchDialog(context, controller),
                        icon: const Icon(
                          Icons.search_rounded,
                          color: Colors.black54,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Obx(() {
                final total = controller.totalTablesCount;
                final occupied = controller.occupiedTablesCount;
                final empty = controller.emptyTablesCount;
                final occupiedPct = controller.occupiedPercentage;
                final emptyPct = controller.emptyPercentage;

                return Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'TỔNG BÀN',
                        value: '$total',
                        suffix: 'bàn',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'BÀN CÓ KHÁCH',
                        value: '$occupied',
                        percentage: '$occupiedPct%',
                        percentageColor: const Color(0xFFC62828),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'BÀN ĐANG TRỐNG',
                        value: '$empty',
                        percentage: '$emptyPct%',
                        percentageColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Obx(
                        () => _buildDropdownFilter(
                          label: controller.selectedArea.value,
                          icon: Icons.keyboard_arrow_down_rounded,
                          onTap: () => _showAreaSelection(context, controller),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => _buildDropdownFilter(
                          label: controller.selectedFilterType.value,
                          icon: Icons.filter_list_rounded,
                          onTap: () =>
                              _showFilterTypeSelection(context, controller),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final shouldReload = await Navigator.of(context).push<bool>(
                        MaterialPageRoute<bool>(
                          builder: (_) => const OrderReservationView(),
                        ),
                      );

                      if (shouldReload == true) {
                        await controller.loadTables();
                      }
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text(
                      'Đặt món/bàn',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Obx(() {
                if (controller.searchQuery.value.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Kết quả tìm kiếm: "${controller.searchQuery.value}"',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => controller.updateSearchQuery(''),
                        child: const Icon(
                          Icons.cancel_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.tables.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty &&
                      controller.tables.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: controller.loadTables,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filtered = controller.filteredTables;

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không tìm thấy bàn nào phù hợp.',
                        style: TextStyle(fontSize: 15, color: Colors.black45),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: primaryColor,
                    onRefresh: controller.loadTables,
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24, top: 4),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final table = filtered[index];

                        return TableCard(
                          table: table,
                          onTap: () => _onTableCardTapped(context, table),
                          onMoreTap: () => _onTableAlertTapped(context, table),
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    String? suffix,
    String? percentage,
    Color? percentageColor,
  }) {
    const cardBgColor = Colors.white;
    const borderColor = Color(0xFFF0F2F5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.black54,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              if (suffix != null)
                Text(
                  suffix,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              if (percentage != null)
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: percentageColor ?? Colors.black54,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF1F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E7EE), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4A5568),
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: const Color(0xFF4A5568)),
          ],
        ),
      ),
    );
  }

  Future<void> _onTableCardTapped(
    BuildContext context,
    StaffTableModel table,
  ) async {
    if (table.status == TableStatus.available) {
      _showEmptyTableDialog(context, table);
      return;
    }

    final controller = Get.find<TableController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF9E3A14)),
        );
      },
    );

    final tableDetail = await controller.getTableDetail(table.id);
    final activeOrder = await controller.getActiveOrderByTable(table.id);

    if (!context.mounted) return;

    Navigator.pop(context);

    if (tableDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage.value),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _showTableOrderDetailSheet(context, tableDetail, activeOrder);
  }

  void _showEmptyTableDialog(BuildContext context, StaffTableModel table) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF4FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_seat_outlined,
                  color: Color(0xFF7B8AA1),
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${table.tableNumber} đang trống',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF222938),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bàn hiện chưa có khách. Vui lòng chọn bàn khác hoặc cập nhật trạng thái.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667085),
                  height: 1.35,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Đóng',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _onTableMoreTapped(context, table);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E3A14),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text('Cập nhật bàn'),
            ),
          ],
        );
      },
    );
  }

  void _showTableOrderDetailSheet(
    BuildContext context,
    StaffTableModel table,
    StaffKitchenOrderModel? order,
  ) {
    final items = order?.items ?? const <StaffKitchenOrderItemModel>[];
    final subtotal = _calculateSubtotal(items);
    final serviceTax = subtotal > 0 ? (subtotal * 0.12).round() : 0;
    final total = subtotal + serviceTax;
    final etaText = _estimateEtaLabel(table.id);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.94,
          minChildSize: 0.55,
          maxChildSize: 0.98,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4D8E1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF8D8A8F),
                            size: 18,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Đơn hàng chi tiết',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFB63F1D),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _onTableMoreTapped(context, table);
                          },
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Color(0xFF8D8A8F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      children: [
                        _buildOrderProgressCard(
                          table: table,
                          order: order,
                          etaLabel: etaText,
                        ),
                        const SizedBox(height: 14),
                        const Row(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              color: Color(0xFFB63F1D),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Chi tiết món ăn',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF262429),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (items.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFECE0DD),
                              ),
                            ),
                            child: const Text(
                              'Chưa có món nào trong order của bàn này.',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        else
                          ...items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildOrderItemCard(item),
                            ),
                          ),
                        const SizedBox(height: 8),
                        _buildOrderSummaryCard(
                          table: table,
                          order: order,
                          subtotal: subtotal,
                          serviceTax: serviceTax,
                          total: total,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F8FA),
                      border: Border(
                        top: BorderSide(color: Color(0xFFE8E4E2)),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            label: const Text(
                              'Về trang chủ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB84F32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Sẵn sàng kết nối API thanh toán cho ${table.tableNumber}.',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.payment_rounded,
                              color: Color(0xFFB63F1D),
                              size: 18,
                            ),
                            label: const Text(
                              'Thanh toán',
                              style: TextStyle(
                                color: Color(0xFFB63F1D),
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDDE2EA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onTableMoreTapped(BuildContext context, StaffTableModel table) {
    final controller = Get.find<TableController>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Cập nhật ${table.tableNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('Chuyển thành Bàn trống'),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);

                  await _updateStatusAndShowResult(
                    context: context,
                    controller: controller,
                    table: table,
                    status: TableStatus.available,
                    successMessage:
                        'Đã chuyển ${table.tableNumber} thành bàn trống.',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Chuyển thành Bàn có khách'),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);

                  await _updateStatusAndShowResult(
                    context: context,
                    controller: controller,
                    table: table,
                    status: TableStatus.occupied,
                    successMessage:
                        'Đã chuyển ${table.tableNumber} thành bàn có khách.',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Chuyển thành Đặt trước'),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);

                  await _updateStatusAndShowResult(
                    context: context,
                    controller: controller,
                    table: table,
                    status: TableStatus.reserved,
                    successMessage:
                        'Đã chuyển ${table.tableNumber} thành đặt trước.',
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onTableAlertTapped(
    BuildContext context,
    StaffTableModel table,
  ) async {
    final controller = Get.find<TableController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF9E3A14)),
        );
      },
    );

    final notifications = await controller.getTableNotifications(table.id);

    if (!context.mounted) return;

    Navigator.pop(context);

    final alerts = notifications.map((item) => item.copyWith()).toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final unreadCount = alerts.where((item) => !item.isRead).length;
            final readCount = alerts.length - unreadCount;

            void updateLocalStatus(int id, bool isRead) {
              final index = alerts.indexWhere((item) => item.id == id);
              if (index == -1) return;

              alerts[index] = alerts[index].copyWith(isRead: isRead);
            }

            Future<void> markOneAsRead(TableNotificationModel alert) async {
              if (alert.isRead) return;

              final success =
                  await controller.markNotificationAsReadAndRefresh(alert.id);

              if (!context.mounted) return;

              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(controller.errorMessage.value),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setSheetState(() {
                updateLocalStatus(alert.id, true);
              });
            }

            Future<void> markAllAsRead() async {
              final success =
                  await controller.markAllNotificationsAsReadForTable(table.id);

              if (!context.mounted) return;

              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(controller.errorMessage.value),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setSheetState(() {
                for (var i = 0; i < alerts.length; i++) {
                  alerts[i] = alerts[i].copyWith(isRead: true);
                }
              });
            }

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.86,
              minChildSize: 0.45,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6DAE3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 14, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Thông báo chi tiết',
                                    style: TextStyle(
                                      color: Color(0xFF232938),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'BÀN ${table.tableNumber}',
                                    style: const TextStyle(
                                      color: Color(0xFFB63F1D),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFF0F3F8),
                                minimumSize: const Size(36, 36),
                              ),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFF576073),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE8ECF3)),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                          children: [
                            _buildAlertSectionTitle('THÔNG BÁO'),
                            const SizedBox(height: 10),
                            if (alerts.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE8ECF3),
                                  ),
                                ),
                                child: const Text(
                                  'Không có thông báo mới cho bàn này.',
                                  style: TextStyle(
                                    color: Color(0xFF6C7587),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              ...alerts.map(
                                (alert) => _buildAlertCard(
                                  alert,
                                  onPrimaryAction: () {
                                    markOneAsRead(alert);
                                  },
                                  onSecondaryAction: () {
                                    markOneAsRead(alert);
                                  },
                                ),
                              ),
                            const SizedBox(height: 10),
                            _buildAlertSectionTitle('TỔNG KẾT'),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE8ECF3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.history_toggle_off_rounded,
                                    color: Color(0xFF8D95A5),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Đã xử lý $readCount/${alerts.length} thông báo của bàn này.',
                                      style: const TextStyle(
                                        color: Color(0xFF6D7587),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Color(0xFFE9EDF3)),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: unreadCount == 0 ? null : markAllAsRead,
                            icon: const Icon(
                              Icons.done_all_rounded,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Tất cả đã đọc',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB63F1D),
                              disabledBackgroundColor: const Color(0xFFBDC4D2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAlertSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF495062),
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE4E8F0)),
        ),
      ],
    );
  }

  Widget _buildAlertCard(
    TableNotificationModel alert, {
    required VoidCallback onPrimaryAction,
    required VoidCallback onSecondaryAction,
  }) {
    final style = _notificationStyle(alert.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F6F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(style.icon, color: style.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title.isEmpty
                          ? _notificationTypeLabel(alert.type)
                          : alert.title,
                      style: TextStyle(
                        color: style.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4FA),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        alert.type,
                        style: const TextStyle(
                          color: Color(0xFF5D6675),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                alert.timeLabel,
                style: const TextStyle(
                  color: Color(0xFF7A8394),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.content.isEmpty ? alert.title : alert.content,
            style: const TextStyle(
              color: Color(0xFF222938),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          if (!alert.isRead)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: onPrimaryAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB63F1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _primaryActionLabel(alert.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: onSecondaryAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6EAF2),
                        foregroundColor: const Color(0xFF5F6674),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Bỏ qua',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F5EB),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Align(
                alignment: Alignment.center,
                child: Text(
                  'Đã đọc',
                  style: TextStyle(
                    color: Color(0xFF1F8A56),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _notificationTypeLabel(String type) {
    return switch (type) {
      'CALL_STAFF' => 'Gọi nhân viên',
      'NEW_ORDER' => 'Đơn món mới',
      'NEW_RESERVATION' => 'Đơn đặt bàn',
      'PAYMENT_REQUEST' => 'Yêu cầu thanh toán',
      _ => 'Yêu cầu khác',
    };
  }

  String _primaryActionLabel(String type) {
    return switch (type) {
      'CALL_STAFF' => 'Tiếp nhận',
      'NEW_ORDER' => 'Xem đơn',
      'PAYMENT_REQUEST' => 'Xác nhận',
      _ => 'Ghi nhận',
    };
  }

  _NotificationAlertStyle _notificationStyle(String type) {
    return switch (type) {
      'CALL_STAFF' => const _NotificationAlertStyle(
          icon: Icons.notifications_active_outlined,
          color: Color(0xFF4A4F5A),
        ),
      'NEW_ORDER' => const _NotificationAlertStyle(
          icon: Icons.receipt_long_rounded,
          color: Color(0xFF2D5E9E),
        ),
      'PAYMENT_REQUEST' => const _NotificationAlertStyle(
          icon: Icons.payments_outlined,
          color: Color(0xFFB63F1D),
        ),
      _ => const _NotificationAlertStyle(
          icon: Icons.info_outline_rounded,
          color: Color(0xFF7A5A1A),
        ),
    };
  }

  Widget _buildOrderProgressCard({
    required StaffTableModel table,
    required StaffKitchenOrderModel? order,
    required String etaLabel,
  }) {
    final status = order?.status;
    final currentStep = switch (status) {
      KitchenOrderStatus.completed => 2,
      KitchenOrderStatus.inProgress => 1,
      KitchenOrderStatus.pending => 0,
      null => table.status == TableStatus.occupied ? 1 : 0,
    };

    Widget buildStep({
      required String label,
      required IconData icon,
      required int step,
    }) {
      final isDone = step <= currentStep;
      final color = isDone ? const Color(0xFFB63F1D) : const Color(0xFFD8DDE8);
      final iconColor = isDone ? Colors.white : const Color(0xFF7B8394);

      return Expanded(
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, size: 13, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDone
                    ? const Color(0xFFB63F1D)
                    : const Color(0xFF8A93A6),
              ),
            ),
          ],
        ),
      );
    }

    final preparingLabel = switch (status) {
      KitchenOrderStatus.completed => 'Đã hoàn tất',
      KitchenOrderStatus.inProgress => 'Đang chuẩn bị',
      KitchenOrderStatus.pending => 'Đã xác nhận',
      null => table.status == TableStatus.reserved
          ? 'Đã xác nhận'
          : 'Đang chuẩn bị',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8DDD9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRẠNG THÁI ĐƠN HÀNG',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                preparingLabel,
                style: const TextStyle(
                  color: Color(0xFFB63F1D),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Dự kiến',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    etaLabel,
                    style: const TextStyle(
                      color: Color(0xFF232938),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE9D8D3), height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              buildStep(
                label: 'Đã xác nhận',
                icon: Icons.check_rounded,
                step: 0,
              ),
              Container(width: 14, height: 1, color: const Color(0xFFE4D2CD)),
              buildStep(
                label: 'Đang chuẩn bị',
                icon: Icons.soup_kitchen_rounded,
                step: 1,
              ),
              Container(width: 14, height: 1, color: const Color(0xFFE4D2CD)),
              buildStep(
                label: 'Đang giao',
                icon: Icons.local_shipping_rounded,
                step: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(StaffKitchenOrderItemModel item) {
    final itemName =
        item.name.trim().isEmpty ? 'Món #${item.dishId ?? ''}' : item.name;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECE0DD)),
      ),
      child: Row(
        children: [
          _buildDishPlaceholder(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        itemName,
                        style: const TextStyle(
                          color: Color(0xFF222938),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6E5DF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          color: Color(0xFFB63F1D),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.note == null || item.note!.trim().isEmpty
                      ? 'Ghi chú: Không có'
                      : 'Ghi chú: ${item.note}',
                  style: const TextStyle(
                    color: Color(0xFF7B808D),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                alignment: Alignment.centerRight,
                child: Text(
                  item.price == null ? 'Đang cập nhật giá' : _formatCurrency(item.totalPrice),
                  style: const TextStyle(
                    color: Color(0xFFB63F1D),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishPlaceholder() {
    return Container(
      width: 72,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAF0),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant_menu_rounded,
        color: Color(0xFF9CA3AF),
      ),
    );
  }

  Widget _buildOrderSummaryCard({
    required StaffTableModel table,
    required StaffKitchenOrderModel? order,
    required int subtotal,
    required int serviceTax,
    required int total,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECE0DD)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.chair_alt_rounded,
                size: 17,
                color: Color(0xFF66656B),
              ),
              const SizedBox(width: 6),
              Text(
                'Vị trí: ${table.tableNumber}',
                style: const TextStyle(
                  color: Color(0xFF4A4A4F),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.fingerprint_rounded,
                size: 17,
                color: Color(0xFF66656B),
              ),
              const SizedBox(width: 6),
              Text(
                order == null ? 'Mã đơn: Chưa có' : 'Mã đơn: #${order.id}',
                style: const TextStyle(
                  color: Color(0xFF4A4A4F),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE8E4E2), height: 1),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: 'Tạm tính',
            value: subtotal > 0 ? _formatCurrency(subtotal) : 'Đang cập nhật',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: 'Phí phục vụ & Thuế (12%)',
            value: serviceTax > 0 ? _formatCurrency(serviceTax) : 'Đang cập nhật',
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE9D3CC), height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tổng thanh toán',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF262429),
                  ),
                ),
              ),
              Text(
                total > 0 ? _formatCurrency(total) : 'Đang cập nhật',
                style: const TextStyle(
                  color: Color(0xFFB63F1D),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({required String label, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5B616E),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF5B616E),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  int _calculateSubtotal(List<StaffKitchenOrderItemModel> items) {
  return items.fold<int>(
    0,
    (sum, item) => sum + item.totalPrice,
  );
}

  String _estimateEtaLabel(int tableId) {
    final min = 15 + ((tableId * 3) % 6);
    final max = min + 5;
    return '$min-$max phút';
  }

  String _formatCurrency(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }

  Future<void> _updateStatusAndShowResult({
    required BuildContext context,
    required TableController controller,
    required StaffTableModel table,
    required TableStatus status,
    required String successMessage,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF9E3A14)),
        );
      },
    );

    final success = await controller.updateTableStatus(
      tableId: table.id,
      status: status,
    );

    if (!context.mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : controller.errorMessage.value),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _showSearchDialog(BuildContext context, TableController controller) {
    final textController = TextEditingController(
      text: controller.searchQuery.value,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Tìm kiếm bàn',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nhập số bàn (vd: T-01, 1)...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              controller.updateSearchQuery(value.trim());
              Navigator.pop(context);
            },
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

  void _showAreaSelection(BuildContext context, TableController controller) {
    final areas = ['Sảnh', 'Phòng VIP', 'Ngoài trời'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Chọn Khu Vực',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                ...areas.map(
                  (area) => ListTile(
                    title: Text(
                      area,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: controller.selectedArea.value == area
                        ? const Icon(Icons.check, color: Color(0xFF9E3A14))
                        : null,
                    onTap: () {
                      controller.changeArea(area);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterTypeSelection(
    BuildContext context,
    TableController controller,
  ) {
    final filters = ['Tất cả', 'Bàn trống', 'Bàn có khách', 'Đặt trước'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Lọc theo trạng thái',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                ...filters.map(
                  (filter) => ListTile(
                    title: Text(
                      filter,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: controller.selectedFilterType.value == filter
                        ? const Icon(Icons.check, color: Color(0xFF9E3A14))
                        : null,
                    onTap: () {
                      controller.changeFilterType(filter);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationAlertStyle {
  const _NotificationAlertStyle({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}