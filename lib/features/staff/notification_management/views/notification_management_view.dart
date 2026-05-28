import 'package:flutter/material.dart';

class NotificationManagementView extends StatefulWidget {
  const NotificationManagementView({super.key});

  @override
  State<NotificationManagementView> createState() =>
      _NotificationManagementViewState();
}

class _NotificationManagementViewState
    extends State<NotificationManagementView> {
  static const Color _primaryColor = Color(0xFF9E3A14);
  static const Color _surfaceBg = Color(0xFFFCFCFC);
  static const Color _mutedText = Color(0xFF6B7280);

  late List<_NotificationGroup> _groups;
  String _sortLabel = 'Thời gian';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _groups = _buildSeedGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceBg,
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshMockData,
        backgroundColor: _primaryColor,
        elevation: 6,
        child: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildTitleArea(context),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  color: _primaryColor,
                  onRefresh: _refreshMockData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 96),
                    children: [
                      if (_visibleGroups().isEmpty)
                        _EmptyState(
                          selectedDate: _selectedDate == null
                              ? ''
                              : _formatDate(_selectedDate!),
                          onClearDate: () {
                            setState(() {
                              _selectedDate = null;
                            });
                          },
                        )
                      else
                        for (final group in _visibleGroups())
                          _NotificationGroupSection(
                            group: group,
                            onProcess: _markProcessed,
                            onDelete: _deleteNotification,
                          ),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: _primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Quản lý thông báo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E7DF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _primaryColor.withValues(alpha: 0.2),
                  width: 1.2,
                ),
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: _primaryColor,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 13,
                height: 13,
                decoration: const BoxDecoration(
                  color: Color(0xFFC62828),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: const Center(
                  child: Text(
                    '5',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleArea(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông báo từ bàn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'Theo dõi và xử lý các yêu cầu từ khách hàng tại bàn',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: _mutedText,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _FilterPill(
              label: _sortLabel,
              icon: Icons.filter_list_rounded,
              onTap: () => _showSortSheet(context),
            ),
            const SizedBox(width: 8),
            _FilterPill(
              label: _selectedDate == null
                  ? 'Tất cả ngày'
                  : _formatDate(_selectedDate!),
              icon: Icons.calendar_month_rounded,
              onTap: () => _showDatePicker(context),
            ),
          ],
        ),
      ],
    );
  }

  List<_NotificationGroup> _visibleGroups() {
    final groups = List<_NotificationGroup>.from(_sortedGroups());

    if (_selectedDate != null) {
      groups.retainWhere((group) => _isSameDay(group.sortKey, _selectedDate!));
    }

    return groups;
  }

  List<_NotificationGroup> _sortedGroups() {
    final groups = List<_NotificationGroup>.from(_groups);
    groups.sort((a, b) => b.sortKey.compareTo(a.sortKey));

    if (_sortLabel == 'Cũ nhất') {
      return groups.reversed.toList();
    }

    return groups;
  }

  Future<void> _refreshMockData() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    setState(() {
      _groups = _buildSeedGroups();
    });
  }

  void _markProcessed(int notificationId) {
    setState(() {
      for (final group in _groups) {
        for (final item in group.items) {
          if (item.id == notificationId) {
            item.isProcessed = true;
            return;
          }
        }
      }
    });
  }

  void _deleteNotification(int notificationId) {
    setState(() {
      for (final group in _groups) {
        group.items.removeWhere((item) => item.id == notificationId);
      }
      _groups.removeWhere((group) => group.items.isEmpty);
    });
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final options = ['Thời gian', 'Mới nhất', 'Cũ nhất'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sắp xếp thông báo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              const Divider(height: 1),
              ...options.map((option) {
                final isSelected = _sortLabel == option;
                return ListTile(
                  title: Text(
                    option,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: _primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _sortLabel = option;
                    });
                    Navigator.pop(sheetContext);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Chọn ngày thông báo',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: _primaryColor),
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  List<_NotificationGroup> _buildSeedGroups() {
    return [
      _NotificationGroup(
        label: 'HÔM NAY',
        sortKey: DateTime(2026, 5, 29, 10, 0),
        items: [
          _NotificationItem(
            id: 1,
            tableLabel: 'Bàn T-01',
            timeLabel: '18:30:00',
            typeLabel: 'THANH TOÁN',
            shortLabel: 'Yêu cầu tính tiền',
            message: '"Tôi muốn thanh toán bằng thẻ tín dụng."',
            icon: Icons.receipt_long_rounded,
            accentColor: Color(0xFFE4572E),
            bubbleColor: Color(0xFFEFF4FF),
            isProcessed: false,
          ),
          _NotificationItem(
            id: 4,
            tableLabel: 'Khách hàng',
            timeLabel: '19:00:00',
            typeLabel: 'ĐẶT BÀN',
            shortLabel: 'Khách đã đặt bàn',
            message:
                '"Người dùng Nguyễn Văn A đã đặt bàn vào lúc 19:00 ngày 29/05/2026."',
            icon: Icons.event_seat_rounded,
            accentColor: Color(0xFF2563EB),
            bubbleColor: Color(0xFFEFF6FF),
            isProcessed: false,
          ),
          _NotificationItem(
            id: 2,
            tableLabel: 'Bàn T-04',
            timeLabel: '18:10:00',
            typeLabel: 'GHI CHÚ NHÂN VIÊN',
            shortLabel: 'Hỗ trợ tại bàn',
            message: '"Cho tôi xin thêm nước tương và ớt tươi, cảm ơn."',
            icon: Icons.notifications_rounded,
            accentColor: Color(0xFF9E3A14),
            bubbleColor: Color(0xFFF2F4F7),
            isProcessed: false,
          ),
        ],
      ),
      _NotificationGroup(
        label: '12/04/2025',
        sortKey: DateTime(2025, 4, 12, 9, 0),
        items: [
          _NotificationItem(
            id: 3,
            tableLabel: 'Bàn T-02',
            timeLabel: '21:14:00',
            typeLabel: 'HỖ TRỢ KHÁC',
            shortLabel: 'Khác',
            message: '"Cho hỏi nhà hàng có ghqtrp em không?"',
            icon: Icons.chat_bubble_outline_rounded,
            accentColor: Color(0xFF94A3B8),
            bubbleColor: Color(0xFFF1F5F9),
            isProcessed: true,
          ),
        ],
      ),
    ];
  }
}

class _NotificationGroupSection extends StatelessWidget {
  const _NotificationGroupSection({
    required this.group,
    required this.onProcess,
    required this.onDelete,
  });

  final _NotificationGroup group;
  final ValueChanged<int> onProcess;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    if (group.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE3E8EF)),
              ),
              child: Text(
                group.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF8A94A6),
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < group.items.length; i++) ...[
            _NotificationCard(
              item: group.items[i],
              onProcess: onProcess,
              onDelete: onDelete,
            ),
            if (i != group.items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onProcess,
    required this.onDelete,
  });

  final _NotificationItem item;
  final ValueChanged<int> onProcess;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    final isProcessed = item.isProcessed;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isProcessed
              ? const Color(0xFFE6EAEE)
              : const Color(0xFFEAD8CE),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.accentColor, size: 19),
                ),
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
                              item.tableLabel,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Text(
                            item.timeLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7C8797),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _TypeChip(
                            label: item.typeLabel,
                            color: item.accentColor,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '•',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB8C0CC),
                              ),
                            ),
                          ),
                          Text(
                            item.shortLabel,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: item.bubbleColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.message,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (isProcessed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Đã xử lý',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE7EBF0),
                    foregroundColor: const Color(0xFF8C97A7),
                    disabledBackgroundColor: const Color(0xFFE7EBF0),
                    disabledForegroundColor: const Color(0xFF8C97A7),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onProcess(item.id),
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                      ),
                      label: const Text(
                        'Đã xử lý',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB24C26),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onDelete(item.id),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text(
                        'Xóa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE4572E),
                        side: const BorderSide(
                          color: Color(0xFFE4572E),
                          width: 1.4,
                        ),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1E6EC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF515D6E)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.selectedDate, required this.onClearDate});

  final String selectedDate;
  final VoidCallback onClearDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE3E8EF)),
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 34,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không có thông báo trong ngày này',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              selectedDate.isEmpty
                  ? 'Đang lọc theo ngày'
                  : 'Ngày đang lọc: $selectedDate',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onClearDate,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9E3A14),
                side: const BorderSide(color: Color(0xFF9E3A14), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Bỏ lọc ngày',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationGroup {
  _NotificationGroup({
    required this.label,
    required this.sortKey,
    required this.items,
  });

  final String label;
  final DateTime sortKey;
  final List<_NotificationItem> items;
}

class _NotificationItem {
  _NotificationItem({
    required this.id,
    required this.tableLabel,
    required this.timeLabel,
    required this.typeLabel,
    required this.shortLabel,
    required this.message,
    required this.icon,
    required this.accentColor,
    required this.bubbleColor,
    required this.isProcessed,
  });

  final int id;
  final String tableLabel;
  final String timeLabel;
  final String typeLabel;
  final String shortLabel;
  final String message;
  final IconData icon;
  final Color accentColor;
  final Color bubbleColor;
  bool isProcessed;
}
