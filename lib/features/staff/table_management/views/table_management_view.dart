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
              // Header
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

              // Summary cards
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

              // Filters + order button
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Chức năng Đặt món đang được phát triển.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.white,
                    ),
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

              // Search query indicator
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

              // Table grid
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.tables.isEmpty) {
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
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black45,
                        ),
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
          border: Border.all(
            color: const Color(0xFFE2E7EE),
            width: 1,
          ),
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
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF4A5568),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTableCardTapped(
    BuildContext context,
    StaffTableModel table,
  ) async {
    final controller = Get.find<TableController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF9E3A14),
          ),
        );
      },
    );

    final tableDetail = await controller.getTableDetail(table.id);

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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chi tiết ${tableDetail.tableNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Mã bàn', '${tableDetail.id}'),
              _buildDetailRow('Sức chứa', '${tableDetail.capacity} người'),
              _buildDetailRow('Trạng thái', _getStatusLabel(tableDetail.status)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _onTableMoreTapped(context, tableDetail);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E3A14),
                foregroundColor: Colors.white,
              ),
              child: const Text('Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  void _onTableMoreTapped(
    BuildContext context,
    StaffTableModel table,
  ) {
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
          child: CircularProgressIndicator(
            color: Color(0xFF9E3A14),
          ),
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
        content: Text(
          success ? successMessage : controller.errorMessage.value,
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(TableStatus status) {
    return switch (status) {
      TableStatus.available => 'Bàn trống',
      TableStatus.occupied => 'Bàn có khách',
      TableStatus.reserved => 'Đặt trước',
    };
  }

  void _showSearchDialog(
    BuildContext context,
    TableController controller,
  ) {
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

  void _showAreaSelection(
    BuildContext context,
    TableController controller,
  ) {
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                        ? const Icon(
                            Icons.check,
                            color: Color(0xFF9E3A14),
                          )
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                        ? const Icon(
                            Icons.check,
                            color: Color(0xFF9E3A14),
                          )
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