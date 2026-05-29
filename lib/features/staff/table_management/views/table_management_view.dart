import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/table_controller.dart';
import '../data/models/staff_table_model.dart';
import '../data/models/table_status.dart';
import 'widgets/table_card.dart';

class TableManagementView extends StatelessWidget {
  const TableManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TableController>();

    // Aesthetic Style Constants
    const primaryColor = Color(0xFF9E3A14); // Deep rust brown
    const scaffoldBg = Color(0xFFFCFCFC);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Title, Search, Avatar
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
                      // Search button
                      IconButton(
                        onPressed: () => _showSearchDialog(context, controller),
                        icon: const Icon(
                          Icons.search_rounded,
                          color: Colors.black54,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Avatar
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

              // 2. Summary Indicator Cards Row
              Obx(() {
                final total = controller.totalTablesCount;
                final occupied = controller.occupiedTablesCount;
                final empty = controller.emptyTablesCount;
                final occupiedPct = controller.occupiedPercentage;
                final emptyPct = controller.emptyPercentage;

                return Row(
                  children: [
                    // Card 1: TỔNG BÀN
                    Expanded(
                      child: _buildMetricCard(
                        title: 'TỔNG BÀN',
                        value: '$total',
                        suffix: 'bàn',
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Card 2: BÀN CÓ KHÁCH
                    Expanded(
                      child: _buildMetricCard(
                        title: 'BÀN CÓ KHÁCH',
                        value: '$occupied',
                        percentage: '$occupiedPct%',
                        percentageColor: const Color(0xFFC62828), // Alert Red
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Card 3: BÀN ĐANG TRỐNG
                    Expanded(
                      child: _buildMetricCard(
                        title: 'BÀN ĐANG TRỐNG',
                        value: '$empty',
                        percentage: '$emptyPct%',
                        percentageColor: const Color(0xFF2E7D32), // Green
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),

              // 3. Filters Row: Sảnh v, Tất cả v, + Đặt món
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Sảnh filter dropdown
                      Obx(
                        () => _buildDropdownFilter(
                          label: controller.selectedArea.value,
                          icon: Icons.keyboard_arrow_down_rounded,
                          onTap: () => _showAreaSelection(context, controller),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tất cả filter dropdown
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

                  // + Đặt món primary button
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Chức năng Đặt món đang được phát triển.',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text(
                      'Đặt món',
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

              // Search query indicator if search active
              Obx(() {
                if (controller.searchQuery.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(
                        'Kết quả tìm kiếm: "${controller.searchQuery.value}"',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
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

              // 4. Refreshable Grid of Table Cards
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
                            onPressed: controller.loadTables,
                            child: const Text('Thử lại'),
                          ),
                        ],
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
                          onMoreTap: () => _onTableMoreTapped(context, table),
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

  // Metric visual item builder
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

  // Beautiful rounded dropdown pill
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

  // Handle tap actions
  void _onTableCardTapped(BuildContext context, StaffTableModel table) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Xem chi tiết bàn ${table.tableNumber}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onTableMoreTapped(BuildContext context, StaffTableModel table) {
    _showTableNotificationPopup(context, table);
  }

  void _showTableNotificationPopup(
    BuildContext context,
    StaffTableModel table,
  ) {
    final alerts = _buildMockAlertsForTable(
      table,
    ).map((item) => item.copyWith()).toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.86,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final pendingCount = alerts
                  .where((item) => item.status != _TableAlertStatus.done)
                  .length;
              final resolvedCount = alerts.length - pendingCount;

              void updateAlertStatus(String id, _TableAlertStatus newStatus) {
                final index = alerts.indexWhere((item) => item.id == id);
                if (index == -1) return;
                alerts[index] = alerts[index].copyWith(status: newStatus);
              }

              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFDFDFE),
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
                      padding: const EdgeInsets.fromLTRB(18, 14, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Th\u00f4ng b\u00e1o chi ti\u1ebft',
                                  style: TextStyle(
                                    color: Color(0xFF1F2430),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'B\u00c0N ${table.tableNumber}',
                                  style: const TextStyle(
                                    color: Color(0xFFB63F1D),
                                    fontSize: 13,
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
                              color: Color(0xFF4B5567),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE9EDF3)),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        children: [
                          _buildNotificationSectionTitle('H\u00d4M NAY'),
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
                                'Kh\u00f4ng c\u00f3 th\u00f4ng b\u00e1o m\u1edbi cho b\u00e0n n\u00e0y.',
                                style: TextStyle(
                                  color: Color(0xFF6C7587),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else
                            ...alerts.map(
                              (alert) => _buildNotificationCard(
                                alert: alert,
                                onPrimaryAction: () {
                                  setSheetState(() {
                                    final nextStatus =
                                        alert.type == _TableAlertType.payment
                                        ? _TableAlertStatus.done
                                        : _TableAlertStatus.processing;
                                    updateAlertStatus(alert.id, nextStatus);
                                  });
                                },
                                onSecondaryAction: () {
                                  setSheetState(() {
                                    updateAlertStatus(
                                      alert.id,
                                      _TableAlertStatus.done,
                                    );
                                  });
                                },
                                onDismissAction: () {
                                  setSheetState(() {
                                    updateAlertStatus(
                                      alert.id,
                                      _TableAlertStatus.done,
                                    );
                                  });
                                },
                              ),
                            ),
                          const SizedBox(height: 10),
                          _buildNotificationSectionTitle(
                            'L\u1ecaCH S\u1eec (${_todayLabel()})',
                          ),
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
                                    '\u0110\u00e3 x\u1eed l\u00fd ${resolvedCount + table.id} y\u00eau c\u1ea7u t\u1eeb b\u00e0n n\u00e0y trong h\u00f4m nay.',
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
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
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
                          onPressed: pendingCount == 0
                              ? null
                              : () {
                                  setSheetState(() {
                                    for (var i = 0; i < alerts.length; i++) {
                                      alerts[i] = alerts[i].copyWith(
                                        status: _TableAlertStatus.done,
                                      );
                                    }
                                  });
                                },
                          icon: const Icon(
                            Icons.done_all_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'T\u1ea5t c\u1ea3 xong',
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
          ),
        );
      },
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$day/$month/${now.year}';
  }

  Widget _buildNotificationSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF495062),
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE4E8F0)),
        ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required _TableAlertItem alert,
    required VoidCallback onPrimaryAction,
    required VoidCallback onSecondaryAction,
    required VoidCallback onDismissAction,
  }) {
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
                child: Icon(alert.icon, color: alert.accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alert.title,
                  style: TextStyle(
                    color: alert.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
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
            alert.message,
            style: const TextStyle(
              color: Color(0xFF222938),
              fontSize: 21,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          if (alert.status == _TableAlertStatus.pending)
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
                        alert.primaryActionLabel,
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
                      child: Text(
                        alert.secondaryActionLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (alert.status == _TableAlertStatus.processing)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D5F5A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        '\u0110ang ti\u1ebfp nh\u1eadn',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: onDismissAction,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFF5D6675),
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
                  '\u0110\u00e3 x\u1eed l\u00fd',
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

  List<_TableAlertItem> _buildMockAlertsForTable(StaffTableModel table) {
    if (table.status == TableStatus.available) {
      return const <_TableAlertItem>[];
    }

    final alerts = <_TableAlertItem>[
      _TableAlertItem(
        id: 'payment-${table.id}',
        title: 'Y\u00eau c\u1ea7u thanh to\u00e1n',
        message: 'T\u00f4i c\u1ea7n thanh to\u00e1n h\u00f3a \u0111\u01a1n.',
        timeLabel: _buildAlertTimeLabel(table.id, 0),
        icon: Icons.payments_outlined,
        accentColor: const Color(0xFFB63F1D),
        type: _TableAlertType.payment,
        primaryActionLabel: 'X\u00e1c nh\u1eadn',
        secondaryActionLabel: 'B\u1ecf qua',
      ),
    ];

    if (table.hasAlert || table.id.isOdd) {
      alerts.add(
        _TableAlertItem(
          id: 'support-${table.id}',
          title: 'G\u1ecdi nh\u00e2n vi\u00ean',
          message:
              'L\u00e0m \u01a1n cho t\u00f4i th\u00eam n\u01b0\u1edbc s\u1ed1t v\u00e0 m\u1ed9t \u00edt \u1edbt t\u01b0\u01a1i, c\u1ea3m \u01a1n.',
          timeLabel: _buildAlertTimeLabel(table.id, 1),
          icon: Icons.notifications_active_outlined,
          accentColor: const Color(0xFF4A4F5A),
          type: _TableAlertType.support,
          status: _TableAlertStatus.processing,
          primaryActionLabel: 'Nh\u1eadn x\u1eed l\u00fd',
          secondaryActionLabel: 'B\u1ecf qua',
        ),
      );
    }

    if (table.id % 3 == 0) {
      alerts.add(
        _TableAlertItem(
          id: 'dish-${table.id}',
          title: 'Y\u00eau c\u1ea7u m\u00f3n th\u00eam',
          message:
              'Cho b\u00e0n t\u00f4i g\u1ecdi th\u00eam 1 ph\u1ea7n salad.',
          timeLabel: _buildAlertTimeLabel(table.id, 2),
          icon: Icons.restaurant_menu_rounded,
          accentColor: const Color(0xFF6F4D1C),
          type: _TableAlertType.extraDish,
          primaryActionLabel: '\u0110\u00e3 nh\u1eadn',
          secondaryActionLabel: 'B\u1ecf qua',
        ),
      );
    }

    return alerts;
  }

  String _buildAlertTimeLabel(int tableId, int step) {
    final hour = 18 + ((tableId + step) % 2);
    final minute = ((tableId * 7) + (step * 13)) % 60;
    final paddedHour = hour.toString().padLeft(2, '0');
    final paddedMinute = minute.toString().padLeft(2, '0');
    return '$paddedHour:$paddedMinute:00';
  }

  // Display Search Dialog
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

  // Display Area selection sheet
  void _showAreaSelection(BuildContext context, TableController controller) {
    final areas = ['Sảnh', 'Phòng VIP', 'Ngoài trời'];
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
        );
      },
    );
  }

  // Display Filter selection sheet
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
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
        );
      },
    );
  }
}

enum _TableAlertType { payment, support, extraDish }

enum _TableAlertStatus { pending, processing, done }

class _TableAlertItem {
  const _TableAlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.accentColor,
    required this.type,
    this.status = _TableAlertStatus.pending,
    this.primaryActionLabel = 'Xác nhận',
    this.secondaryActionLabel = 'Bỏ qua',
  });

  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
  final Color accentColor;
  final _TableAlertType type;
  final _TableAlertStatus status;
  final String primaryActionLabel;
  final String secondaryActionLabel;

  _TableAlertItem copyWith({_TableAlertStatus? status}) {
    return _TableAlertItem(
      id: id,
      title: title,
      message: message,
      timeLabel: timeLabel,
      icon: icon,
      accentColor: accentColor,
      type: type,
      status: status ?? this.status,
      primaryActionLabel: primaryActionLabel,
      secondaryActionLabel: secondaryActionLabel,
    );
  }
}
