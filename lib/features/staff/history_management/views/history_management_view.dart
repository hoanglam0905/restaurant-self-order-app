import 'package:flutter/material.dart';

import '../../../customer/order/data/models/order_detail_model.dart';
import '../../../customer/order/data/models/order_item_model.dart';

class HistoryManagementView extends StatefulWidget {
  const HistoryManagementView({super.key});

  @override
  State<HistoryManagementView> createState() => _HistoryManagementViewState();
}

enum _HistorySortType {
  newest('Mới nhất'),
  oldest('Cũ nhất');

  const _HistorySortType(this.label);
  final String label;
}

enum _HistoryTimeFilter {
  all('Cả ngày'),
  morning('Sáng (00:00 - 11:59)'),
  afternoon('Chiều (12:00 - 17:59)'),
  evening('Tối (18:00 - 23:59)');

  const _HistoryTimeFilter(this.label);
  final String label;
}

class _HistoryManagementViewState extends State<HistoryManagementView> {
  static const Color _primary = Color(0xFFAA3B20);
  static const Color _surface = Color(0xFFF9F6F7);

  final List<OrderDetailModel> _orders = _buildMockOrders();
  DateTime? _selectedDate;
  _HistorySortType _sortType = _HistorySortType.newest;
  _HistoryTimeFilter _timeFilter = _HistoryTimeFilter.all;

  @override
  Widget build(BuildContext context) {
    final groups = _groupedOrders();

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 10),
              _buildTitleBlock(context),
              const SizedBox(height: 12),
              _buildFilterRow(context),
              const SizedBox(height: 10),
              Expanded(
                child: groups.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        color: _primary,
                        onRefresh: () async {
                          await Future<void>.delayed(
                            const Duration(milliseconds: 250),
                          );
                          if (!mounted) return;
                          setState(() {});
                        },
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(0, 6, 0, 94),
                          children: [
                            for (final entry in groups.entries) ...[
                              _SectionLabel(text: entry.key),
                              const SizedBox(height: 14),
                              for (int i = 0; i < entry.value.length; i++) ...[
                                _HistoryOrderCard(
                                  order: entry.value[i],
                                  onViewDetail: () =>
                                      _openOrderDetail(entry.value[i]),
                                  onPrint: () => _showPrintDialog(entry.value[i]),
                                ),
                                if (i != entry.value.length - 1)
                                  const SizedBox(height: 12),
                              ],
                              const SizedBox(height: 16),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: _primary, size: 23),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tìm kiếm sẽ được kết nối sau.')),
              );
            },
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
            child: Icon(Icons.person_rounded, color: _primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBlock(BuildContext context) {
    final dateLabel = _selectedDate == null
        ? 'Hôm nay'
        : _formatDate(_selectedDate!);

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
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _pickDate(context),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAF0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: _primary,
                  size: 15,
                ),
                const SizedBox(width: 7),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterPill(
            icon: Icons.swap_vert_rounded,
            label: _sortType.label,
            onTap: () => _showSortSheet(context),
          ),
          const SizedBox(width: 8),
          _FilterPill(
            icon: Icons.access_time_rounded,
            label: _timeFilter.label,
            onTap: () => _showTimeFilterSheet(context),
          ),
          const SizedBox(width: 8),
          if (_selectedDate != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                });
              },
              child: const Text(
                'Bỏ lọc ngày',
                style: TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, List<OrderDetailModel>> _groupedOrders() {
    final sorted = _filteredAndSortedOrders();
    final grouped = <String, List<OrderDetailModel>>{};
    final now = DateTime.now();

    for (final order in sorted) {
      final date = _orderDate(order);
      final key = _isSameDay(date, now) ? 'HÔM NAY' : _formatDate(date);
      grouped.putIfAbsent(key, () => <OrderDetailModel>[]).add(order);
    }
    return grouped;
  }

  List<OrderDetailModel> _filteredAndSortedOrders() {
    final result = _orders.where((order) {
      final date = _orderDate(order);
      if (_selectedDate != null && !_isSameDay(date, _selectedDate!)) {
        return false;
      }
      return _matchTimeFilter(date);
    }).toList();

    result.sort((a, b) {
      final aDate = _orderDate(a);
      final bDate = _orderDate(b);
      if (_sortType == _HistorySortType.newest) {
        return bDate.compareTo(aDate);
      }
      return aDate.compareTo(bDate);
    });

    return result;
  }

  bool _matchTimeFilter(DateTime dateTime) {
    final hour = dateTime.hour;
    return switch (_timeFilter) {
      _HistoryTimeFilter.all => true,
      _HistoryTimeFilter.morning => hour < 12,
      _HistoryTimeFilter.afternoon => hour >= 12 && hour < 18,
      _HistoryTimeFilter.evening => hour >= 18,
    };
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Chọn ngày',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: _primary),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
    });
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sắp xếp lịch sử',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              const Divider(height: 1),
              for (final type in _HistorySortType.values)
                ListTile(
                  title: Text(
                    type.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: _sortType == type
                      ? const Icon(Icons.check, color: _primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _sortType = type;
                    });
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showTimeFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Lọc theo thời gian',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              const Divider(height: 1),
              for (final filter in _HistoryTimeFilter.values)
                ListTile(
                  title: Text(
                    filter.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: _timeFilter == filter
                      ? const Icon(Icons.check, color: _primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _timeFilter = filter;
                    });
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPrintDialog(OrderDetailModel order) async {
    final allow = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'In lại hóa đơn?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Bạn có muốn in lại bill #${order.orderId.toString().padLeft(4, '0')} không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              child: const Text('In bill'),
            ),
          ],
        );
      },
    );

    if (allow != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã gửi yêu cầu in lại bill #${order.orderId.toString().padLeft(4, '0')} (UI mock).',
        ),
      ),
    );
  }

  Future<void> _openOrderDetail(OrderDetailModel order) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _HistoryOrderDetailPage(order: order),
      ),
    );
  }

  DateTime _orderDate(OrderDetailModel order) {
    return order.reservationTime ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _formatDate(DateTime dateTime) {
    final dd = dateTime.day.toString().padLeft(2, '0');
    final mm = dateTime.month.toString().padLeft(2, '0');
    final yyyy = dateTime.year.toString();
    return '$dd/$mm/$yyyy';
  }
}

class _HistoryOrderCard extends StatelessWidget {
  const _HistoryOrderCard({
    required this.order,
    required this.onViewDetail,
    required this.onPrint,
  });

  final OrderDetailModel order;
  final VoidCallback onViewDetail;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    final date = order.reservationTime ?? DateTime.now();
    final timeLabel =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00';
    final orderCode = order.orderId.toString().padLeft(4, '0');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEED8D2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              children: [
                _TableBadge(tableNumber: order.tableNumber),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã HF : #$orderCode',
                        style: const TextStyle(
                          color: Color(0xFF333236),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF9A9699),
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            timeLabel,
                            style: const TextStyle(
                              color: Color(0xFF9A9699),
                              fontSize: 12,
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
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatCurrency(order.totalAmount),
                        style: const TextStyle(
                          color: Color(0xFFAA3B20),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                _CirclePrintButton(onTap: onPrint),
                const SizedBox(width: 10),
                _DetailButton(onTap: onViewDetail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableBadge extends StatelessWidget {
  const _TableBadge({required this.tableNumber});

  final int tableNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1D5CE)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'BÀN',
              style: TextStyle(
                color: Color(0xFFC97B68),
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'T-${tableNumber.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Color(0xFFAA3B20),
                fontSize: 17,
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
    final paid = status.toUpperCase() == 'PAID';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: paid ? const Color(0xFFEFF9EF) : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        paid ? 'ĐÃ THANH TOÁN' : 'CHƯA THANH TOÁN',
        style: TextStyle(
          color: paid ? const Color(0xFF4C9A4A) : const Color(0xFFC47B1B),
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
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
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
        child: Ink(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEBCBC2)),
          ),
          child: const Icon(
            Icons.print_outlined,
            color: Color(0xFF6D6868),
            size: 19,
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
          width: 108,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFAA3B20),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE9E1E2), height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF8D888C),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE9E1E2), height: 1)),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE3D6D2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF5D5A5E)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5D5A5E),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Không có bill phù hợp với bộ lọc.',
        style: TextStyle(
          color: Color(0xFF7A7479),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HistoryOrderDetailPage extends StatelessWidget {
  const _HistoryOrderDetailPage({required this.order});

  static const Color _primary = Color(0xFFAA3B20);
  final OrderDetailModel order;

  @override
  Widget build(BuildContext context) {
    final subtotal = order.items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );
    final serviceTax = (subtotal * 0.12).roundToDouble();
    final total = subtotal + serviceTax;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8FA),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE7D8D3)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF8D8A8F),
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE7D8D3)),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu_rounded,
                              size: 16,
                              color: Color(0xFF9A9AA0),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Bon Appétit',
                            style: TextStyle(
                              color: _primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        color: _primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Chi tiết món ăn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF262429),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DetailDishCard(item: item),
                    );
                  }),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
                              size: 18,
                              color: Color(0xFF66656B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Vị trí: Bàn ${order.tableNumber.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Color(0xFF4A4A4F),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Icon(
                              Icons.fingerprint_rounded,
                              size: 18,
                              color: Color(0xFF66656B),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Mã đơn: #BA-${order.orderId.toString().padLeft(4, '0')}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Color(0xFF4A4A4F),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFE8E4E2), height: 1),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          label: 'Tạm tính',
                          value: _formatCurrency(subtotal),
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: 'Phí phục vụ & Thuế (12%)',
                          value: _formatCurrency(serviceTax),
                        ),
                        const SizedBox(height: 10),
                        const _DashedLine(color: Color(0xFFE9D3CC)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Tổng thanh toán',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF262429),
                                ),
                              ),
                            ),
                            Text(
                              _formatCurrency(total),
                              style: const TextStyle(
                                color: _primary,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      label: const Text(
                        'Về trang chủ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
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
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _showPrintDialog(context),
                      icon: const Icon(
                        Icons.receipt_long_rounded,
                        color: _primary,
                        size: 18,
                      ),
                      label: const Text(
                        'In PDF',
                        style: TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD0D4DD),
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
      ),
    );
  }

  Future<void> _showPrintDialog(BuildContext context) async {
    final allow = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'In lại hóa đơn?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Bạn có muốn in lại bill #${order.orderId.toString().padLeft(4, '0')} không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              child: const Text('In bill'),
            ),
          ],
        );
      },
    );

    if (allow != true || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã gửi yêu cầu in PDF bill #${order.orderId.toString().padLeft(4, '0')} (UI mock).',
        ),
      ),
    );
  }
}

class _DetailDishCard extends StatelessWidget {
  const _DetailDishCard({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    final imagePath = _imageForDish(item.dishId);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDE4E1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 78,
              height: 78,
              fit: BoxFit.cover,
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
                        item.dishName ?? 'Món ăn',
                        style: const TextStyle(
                          color: Color(0xFF232328),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8E5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          color: Color(0xFFB04F35),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.notes?.isNotEmpty == true
                      ? 'Ghi chú: ${item.notes}'
                      : 'Ghi chú: Phục vụ sau món chính.',
                  style: const TextStyle(
                    color: Color(0xFF6D6D74),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatCurrency(item.subtotal),
                    style: const TextStyle(
                      color: Color(0xFFAA3B20),
                      fontSize: 19,
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
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF66666C),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF55555B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 7).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => SizedBox(
              width: 4,
              height: 1.2,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _formatCurrency(double amount) {
  final rounded = amount.round();
  final value = rounded.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < value.length; i++) {
    final reverseIndex = value.length - i;
    buffer.write(value[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return '${buffer.toString()}đ';
}

String _imageForDish(int dishId) {
  const images = [
    'assets/images/home/TodaySpecial1.jpg',
    'assets/images/home/TodaySpecial2.jpg',
    'assets/images/home/banner2.jpg',
  ];
  return images[dishId % images.length];
}

List<OrderDetailModel> _buildMockOrders() {
  final now = DateTime.now();
  return [
    OrderDetailModel(
      orderId: 123,
      customerName: 'Khách lẻ',
      tableNumber: 1,
      status: 'COMPLETED',
      totalAmount: 1200000,
      paymentStatus: 'PAID',
      reservationTime: DateTime(now.year, now.month, now.day, 18, 30),
      items: const [
        OrderItemModel(
          dishId: 1,
          dishName: 'Salad Landaise',
          quantity: 1,
          price: 185000,
          notes: 'Ít sốt béo, thêm hạt khô.',
          status: 'COMPLETED',
        ),
        OrderItemModel(
          dishId: 2,
          dishName: 'Magret De Canard',
          quantity: 2,
          price: 175000,
          notes: 'Chín vừa (Medium).',
          status: 'COMPLETED',
        ),
        OrderItemModel(
          dishId: 3,
          dishName: 'Fondant au Chocolat',
          quantity: 1,
          price: 65000,
          notes: 'Phục vụ sau món chính.',
          status: 'COMPLETED',
        ),
      ],
    ),
    OrderDetailModel(
      orderId: 122,
      customerName: 'Khách đoàn',
      tableNumber: 4,
      status: 'COMPLETED',
      totalAmount: 1500000,
      paymentStatus: 'PAID',
      reservationTime: DateTime(now.year, now.month, now.day, 18, 10),
      items: const [
        OrderItemModel(
          dishId: 4,
          dishName: 'Lẩu Thái Hải Sản',
          quantity: 1,
          price: 650000,
          notes: 'Ít cay.',
          status: 'COMPLETED',
        ),
        OrderItemModel(
          dishId: 5,
          dishName: 'Tôm Chiên Bơ Tỏi',
          quantity: 2,
          price: 260000,
          notes: 'Thêm tỏi phi.',
          status: 'COMPLETED',
        ),
        OrderItemModel(
          dishId: 6,
          dishName: 'Nước ngọt',
          quantity: 5,
          price: 66000,
          notes: 'Đá riêng.',
          status: 'COMPLETED',
        ),
      ],
    ),
    OrderDetailModel(
      orderId: 121,
      customerName: 'Khách đặt bàn',
      tableNumber: 4,
      status: 'COMPLETED',
      totalAmount: 980000,
      paymentStatus: 'PAID',
      reservationTime: DateTime(now.year, now.month, now.day - 1, 18, 10),
      items: const [
        OrderItemModel(
          dishId: 7,
          dishName: 'Cá hồi áp chảo',
          quantity: 2,
          price: 310000,
          notes: 'Sốt chanh dây riêng.',
          status: 'COMPLETED',
        ),
        OrderItemModel(
          dishId: 8,
          dishName: 'Mì xào bò',
          quantity: 2,
          price: 180000,
          notes: 'Không hành.',
          status: 'COMPLETED',
        ),
      ],
    ),
    OrderDetailModel(
      orderId: 120,
      customerName: 'Khách lẻ',
      tableNumber: 2,
      status: 'COMPLETED',
      totalAmount: 780000,
      paymentStatus: 'PAID',
      reservationTime: DateTime(now.year, now.month, now.day - 2, 12, 45),
      items: const [
        OrderItemModel(
          dishId: 10,
          dishName: 'Cơm gà quay',
          quantity: 2,
          price: 140000,
          notes: 'Da giòn.',
          status: 'COMPLETED',
        ),
        OrderItemModel(
          dishId: 11,
          dishName: 'Gỏi cuốn tôm thịt',
          quantity: 3,
          price: 95000,
          notes: 'Thêm rau.',
          status: 'COMPLETED',
        ),
        OrderItemModel(
          dishId: 12,
          dishName: 'Sữa tươi trân châu',
          quantity: 2,
          price: 107500,
          notes: 'Ít đá.',
          status: 'COMPLETED',
        ),
      ],
    ),
  ];
}
