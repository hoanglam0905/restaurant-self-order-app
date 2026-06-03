import 'dart:math' as math;

import 'package:flutter/material.dart';

const Color _brandColor = Color(0xFFB63A1B);
const Color _brandSoft = Color(0xFFFFF1EC);
const Color _pageBackground = Color(0xFFF4F7FC);
const Color _textPrimary = Color(0xFF1F2937);
const Color _textMuted = Color(0xFF6B7280);

class OrderReservationView extends StatefulWidget {
  const OrderReservationView({super.key});

  @override
  State<OrderReservationView> createState() => _OrderReservationViewState();
}

class _OrderReservationViewState extends State<OrderReservationView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reservationSearchController =
      TextEditingController();

  int _activeTopTab = 0;
  int _selectedTableIndex = 0;
  int _selectedCategoryIndex = 0;
  int _reservationStatusTab = 0;
  String _searchText = '';
  String _reservationSearchText = '';

  final List<String> _tables = const ['T-01', 'T-02', 'T-03', 'T-04', 'T-05'];
  final List<String> _categories = const [
    'Tất cả',
    'Khai vị',
    'Món chính',
    'Tráng miệng',
  ];

  final List<_MenuItem> _menuItems = const [
    _MenuItem(
      name: 'Salad Landaise',
      description: 'Rau xanh & sốt đặc biệt',
      note: 'Không hành, sốt để riêng',
      category: 'Khai vị',
      price: 185000,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=300&h=300&fit=crop',
    ),
    _MenuItem(
      name: 'Magret De Canard',
      description: 'Ức vịt áp chảo & sốt vang',
      note: 'Tái vừa (Medium-rare)',
      category: 'Món chính',
      price: 295000,
      imageUrl:
          'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=300&h=300&fit=crop',
    ),
    _MenuItem(
      name: 'Fondant au Chocolat',
      description: 'Socola nóng & kem vani',
      note: 'Thêm 1 viên kem vani',
      category: 'Tráng miệng',
      price: 120000,
      imageUrl:
          'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=300&h=300&fit=crop',
    ),
    _MenuItem(
      name: 'Cá Hồi Áp Chảo',
      description: 'Sốt bơ chanh & măng tây',
      note: 'Ít sốt béo, thêm hạt khô',
      category: 'Món chính',
      price: 285000,
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=300&h=300&fit=crop',
    ),
  ];

  late final List<int> _quantities;

  final List<_ReservationRequest> _reservationRequests = [
    _ReservationRequest(
      customerName: 'Nguyễn Văn An',
      timeLabel: '18:30 • Hôm nay',
      statusLabel: 'Đang chờ',
      statusColor: Color(0xFFFFF1EC),
      statusTextColor: _brandColor,
      guestCount: 4,
      detailLabel: '06 món đặt trước',
      tableNumber: 'Bàn 12',
      highlightTitle: 'Món đặt trước nổi bật:',
      highlightItems: 'Salad Hy Lạp Cao Cấp, Súp Bào Ngư, Lemon Macarons...',
      highlightTotal: 2450000,
    ),
    _ReservationRequest(
      customerName: 'Trần Thị Hoa',
      timeLabel: '19:15 • Hôm nay',
      statusLabel: 'Yêu cầu mới',
      statusColor: Color(0xFFEFEFEF),
      statusTextColor: Color(0xFF6B7280),
      guestCount: 2,
      detailLabel: 'Chưa đặt món',
      tableNumber: 'Chưa chọn bàn',
    ),
    _ReservationRequest(
      customerName: 'Lê Hoàng Nam',
      timeLabel: '20:00 • Hôm nay',
      statusLabel: 'Đã xử lý',
      statusColor: Color(0xFFEAF8EE),
      statusTextColor: Color(0xFF208C44),
      guestCount: 6,
      detailLabel: 'Đã gán bàn 12',
      tableNumber: 'Bàn 12',
      phoneNumber: '0912 345 678',
      highlightTitle: 'Ghi chú:',
      highlightItems: 'Khách đến muộn khoảng 10 phút, ưu tiên bàn gần cửa sổ.',
      isProcessed: true,
    ),
    _ReservationRequest(
      customerName: 'Phạm Minh Quân',
      timeLabel: '18:30 • Hôm qua',
      statusLabel: 'Đã xử lý',
      statusColor: Color(0xFFEAF8EE),
      statusTextColor: Color(0xFF208C44),
      guestCount: 3,
      detailLabel: '03 món đặt trước',
      tableNumber: 'Bàn 08',
      phoneNumber: '0908 222 333',
      highlightTitle: 'Món đã xác nhận:',
      highlightItems: 'Salad Landaise x1, Magret De Canard x1, Fondant au Chocolat x1',
      highlightTotal: 600000,
      isProcessed: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _quantities = List<int>.filled(_menuItems.length, 0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reservationSearchController.dispose();
    super.dispose();
  }

  Iterable<MapEntry<int, _MenuItem>> get _filteredMenuEntries {
    return _menuItems.asMap().entries.where((entry) {
      final item = entry.value;
      final matchesCategory = _selectedCategoryIndex == 0 ||
          item.category == _categories[_selectedCategoryIndex];
      final normalizedSearch = _searchText.trim().toLowerCase();
      final matchesSearch = normalizedSearch.isEmpty ||
          item.name.toLowerCase().contains(normalizedSearch) ||
          item.description.toLowerCase().contains(normalizedSearch);
      return matchesCategory && matchesSearch;
    });
  }

  int get _selectedItemCount =>
      _quantities.fold<int>(0, (total, quantity) => total + quantity);

  int get _selectedTotal {
    var total = 0;
    for (var i = 0; i < _menuItems.length; i++) {
      total += _menuItems[i].price * _quantities[i];
    }
    return total;
  }

  List<MapEntry<int, _MenuItem>> get _selectedMenuEntries {
    return _menuItems
        .asMap()
        .entries
        .where((entry) => _quantities[entry.key] > 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                _buildHeader(),
                _buildTopSwitcher(),
                Expanded(
                  child: IndexedStack(
                    index: _activeTopTab,
                    children: [
                      _buildOrderTab(),
                      _buildReserveTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: _brandColor, size: 22),
            onPressed: () => Navigator.maybePop(context),
          ),
          const Expanded(
            child: Text(
              'Tạo đơn hàng/đặt bàn',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _brandColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 22),
                onPressed: () {},
              ),
              Positioned(
                top: 6,
                right: 7,
                child: Container(
                  width: 15,
                  height: 15,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _brandColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 2),
          const CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFFD4512A),
            child: Text(
              'JD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildTopSwitcher() {
    final pendingCount =
        _reservationRequests.where((request) => !request.isProcessed).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFE3E9F2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            _buildTopTabButton('Tạo đơn hàng', 0),
            _buildTopTabButton('Đặt bàn', 1, badge: pendingCount),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTabButton(String label, int index, {int? badge}) {
    final isActive = _activeTopTab == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _activeTopTab = index),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? _brandColor : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _brandColor.withOpacity(0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : _textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (badge != null && badge > 0)
                Positioned(
                  top: -12,
                  right: -18,
                  child: Container(
                    width: 17,
                    height: 17,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _brandColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 2, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  title: 'Bàn phục vụ',
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Tất cả',
                      style: TextStyle(
                        color: _brandColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                _buildTableSelector(),
                const SizedBox(height: 14),
                _buildSearchField(),
                const SizedBox(height: 12),
                _buildCategoryTabs(),
                const SizedBox(height: 12),
                ..._filteredMenuEntries.map(
                  (entry) => _buildMenuCard(entry.key, entry.value),
                ),
              ],
            ),
          ),
        ),
        if (_selectedItemCount > 0) _buildOrderFooter(),
      ],
    );
  }

  Widget _buildSectionTitle({required String title, Widget? trailing}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildTableSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tables.length, (index) {
          final isActive = _selectedTableIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: () => setState(() => _selectedTableIndex = index),
              child: Container(
                height: 34,
                constraints: const BoxConstraints(minWidth: 54),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isActive ? _brandColor : Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isActive ? _brandColor : const Color(0xFFE3E8EF),
                  ),
                ),
                child: Text(
                  _tables[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : _textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchText = value),
        style: const TextStyle(fontSize: 13, color: _textPrimary),
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: _textMuted, size: 20),
          hintText: 'Tìm món ăn hoặc đồ uống...',
          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isActive = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 18),
            child: InkWell(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Text(
                      _categories[index],
                      style: TextStyle(
                        color: isActive ? _brandColor : _textPrimary,
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 2,
                      width: 42,
                      color: isActive ? _brandColor : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMenuCard(int index, _MenuItem item) {
    final quantity = _quantities[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DCD8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDishImage(item.imageUrl, size: 72, radius: 10),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  _formatCurrency(item.price),
                  style: const TextStyle(
                    color: _brandColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildQuantityControl(
            quantity: quantity,
            onMinus: () {
              if (quantity == 0) return;
              setState(() => _quantities[index]--);
            },
            onPlus: () => setState(() => _quantities[index]++),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl({
    required int quantity,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRoundCounterButton(
          icon: Icons.remove,
          active: quantity > 0,
          onTap: onMinus,
        ),
        SizedBox(
          width: 26,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _buildRoundCounterButton(
          icon: Icons.add,
          active: true,
          onTap: onPlus,
        ),
      ],
    );
  }

  Widget _buildRoundCounterButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 23,
        height: 23,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _brandColor : const Color(0xFFE9EEF5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : _textMuted,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildOrderFooter() {
    final selectedEntries = _selectedMenuEntries;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _brandColor.withOpacity(0.18)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 116,
                height: 30,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 4,
                      child: Container(
                        width: 21,
                        height: 21,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: _brandColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_selectedItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    ...List.generate(
                      math.min(selectedEntries.length, 3),
                      (index) => Positioned(
                        left: 22.0 + index * 18,
                        top: 2,
                        child: _buildCircularDishThumb(
                          selectedEntries[index].value.imageUrl,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _showOrderDetailSheet,
                child: const Text(
                  'Xem chi tiết ^',
                  style: TextStyle(
                    color: _brandColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Tổng cộng ($_selectedItemCount món)',
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _formatCurrency(_selectedTotal),
                style: const TextStyle(
                  color: _brandColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: _brandColor.withOpacity(0.26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text(
                'XÁC NHẬN ĐƠN HÀNG',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailSheet() {
    if (_selectedMenuEntries.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selectedEntries = _selectedMenuEntries;
            final screenHeight = MediaQuery.of(sheetContext).size.height;
            final maxSheetHeight = screenHeight * 0.78;
            final maxListHeight = screenHeight * 0.36;
            final listHeight = math.min(
              selectedEntries.length * 80.0,
              maxListHeight,
            );

            return SafeArea(
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                constraints: BoxConstraints(maxHeight: maxSheetHeight),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4C8BE),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 6),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Chi tiết đơn hàng',
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close, color: _textMuted),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F4F8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: listHeight,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: selectedEntries.length,
                        separatorBuilder: (_, __) => Divider(
                          color: _brandColor.withOpacity(0.18),
                          height: 16,
                        ),
                        itemBuilder: (context, index) {
                          final entry = selectedEntries[index];
                          final item = entry.value;
                          final quantity = _quantities[entry.key];

                          return Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _buildDishImage(
                                    item.imageUrl,
                                    size: 58,
                                    radius: 9,
                                  ),
                                  Positioned(
                                    right: -4,
                                    top: -4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _brandColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'x$quantity',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: _textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.notes,
                                          color: _textMuted,
                                          size: 13,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            item.note,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: _textMuted,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatCurrency(item.price * quantity),
                                    style: const TextStyle(
                                      color: _brandColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (_quantities[entry.key] > 0) {
                                          _quantities[entry.key]--;
                                        }
                                      });

                                      if (_selectedItemCount == 0) {
                                        Navigator.pop(sheetContext);
                                        return;
                                      }

                                      setSheetState(() {});
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: _textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                      color: const Color(0xFFEFF5FF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Tổng cộng ($_selectedItemCount món)',
                                style: const TextStyle(
                                  color: _textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatCurrency(_selectedTotal),
                                style: const TextStyle(
                                  color: _brandColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.chair, size: 15, color: _textMuted),
                              const SizedBox(width: 5),
                              Text(
                                'Bàn ${_tables[_selectedTableIndex]}',
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _brandColor,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: _brandColor.withOpacity(0.25),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(sheetContext),
                                icon: const Icon(Icons.check_circle, size: 16),
                                label: const Text(
                                  'XÁC NHẬN ĐƠN HÀNG',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.7,
                                  ),
                                ),
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
          },
        );
      },
    );
  }

  Widget _buildReserveTab() {
    final pending = _reservationRequests
        .where((request) => !request.isProcessed)
        .toList(growable: false);
    final processed = _reservationRequests
        .where((request) => request.isProcessed)
        .toList(growable: false);
    final sourceRequests = _reservationStatusTab == 0 ? pending : processed;
    final normalizedSearch = _reservationSearchText.trim().toLowerCase();
    final visibleRequests = normalizedSearch.isEmpty
        ? sourceRequests
        : sourceRequests
            .where(
              (request) =>
                  request.customerName.toLowerCase().contains(normalizedSearch),
            )
            .toList(growable: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yêu cầu đặt bàn',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Các lịch đặt bàn mới\ntrong hôm nay',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _openReservationForm(
                    _ReservationRequest(
                      customerName: '',
                      timeLabel: '18:30 • Hôm nay',
                      statusLabel: 'Tạo mới',
                      statusColor: _brandSoft,
                      statusTextColor: _brandColor,
                      guestCount: 2,
                      detailLabel: 'Chưa đặt món',
                      tableNumber: 'Chưa chọn bàn',
                    ),
                    appendIfNew: true,
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'Đặt bàn trực tiếp',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildReservationStatusTabs(pending.length, processed.length),
          const SizedBox(height: 12),
          _buildReservationSearchField(),
          const SizedBox(height: 12),
          if (visibleRequests.isEmpty)
            _buildEmptyReservationState()
          else
            ...visibleRequests.map(_buildReservationCard),
        ],
      ),
    );
  }

  Widget _buildReservationSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE3E8EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _reservationSearchController,
        onChanged: (value) => setState(() => _reservationSearchText = value),
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: _textMuted, size: 19),
          suffixIcon: _reservationSearchText.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _reservationSearchController.clear();
                    setState(() => _reservationSearchText = '');
                  },
                  icon: const Icon(Icons.close, color: _textMuted, size: 16),
                ),
          hintText: 'Tìm theo tên khách đặt bàn...',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 12,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _buildReservationStatusTabs(int pendingCount, int processedCount) {
    final labels = [
      'Chờ duyệt ($pendingCount)',
      'Đã xử lý ($processedCount)',
    ];

    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E9F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = _reservationStatusTab == index;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _reservationStatusTab = index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? _brandColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : _textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyReservationState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_available, color: _textMuted, size: 30),
          SizedBox(height: 8),
          Text(
            'Chưa có lịch trong mục này',
            style: TextStyle(
              color: _textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(_ReservationRequest request) {
    final canDelete = request.isProcessed;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: request.isProcessed ? () => _showProcessedReservationInfo(request) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8DCD8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0EFEC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, color: _textMuted),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.customerName.isEmpty
                            ? 'Khách đặt trực tiếp'
                            : request.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 13, color: _textMuted),
                          const SizedBox(width: 4),
                          Text(
                            request.timeLabel,
                            style: const TextStyle(
                              color: _textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: request.statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.statusLabel,
                    style: TextStyle(
                      color: request.statusTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.black.withOpacity(0.06), height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildReservationMeta(
                  Icons.people_outline,
                  '${request.guestCount.toString().padLeft(2, '0')} khách',
                ),
                const SizedBox(width: 14),
                _buildReservationMeta(
                  request.isProcessed ? Icons.chair_outlined : Icons.restaurant_menu,
                  request.isProcessed ? request.tableNumber : request.detailLabel,
                ),
              ],
            ),
            if (request.highlightItems != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.highlightTitle ?? 'Ghi chú:',
                            style: const TextStyle(
                              color: _textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (request.highlightTotal != null)
                          Text(
                            _formatCurrency(request.highlightTotal!),
                            style: const TextStyle(
                              color: _brandColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.highlightItems!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 10,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            if (request.isProcessed)
              Row(
                children: [
                  if (canDelete) ...[
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD33A2C),
                            side: const BorderSide(color: Color(0xFFD33A2C)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _deleteProcessedReservation(request),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text(
                            'Xóa',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: canDelete ? 2 : 1,
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _brandColor,
                          side: BorderSide(color: _brandColor.withOpacity(0.35)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _showProcessedReservationInfo(request),
                        child: const Text(
                          'Xem thông tin đặt bàn',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8B6F65),
                          side: BorderSide(color: _brandColor.withOpacity(0.45)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã bỏ qua yêu cầu đặt bàn.'),
                            ),
                          );
                        },
                        child: const Text(
                          'Từ chối',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _openReservationForm(request),
                        child: const Text(
                          'Chấp nhận',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
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

  void _deleteProcessedReservation(_ReservationRequest request) {
    setState(() => _reservationRequests.remove(request));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa lịch đặt bàn đã xử lý.')),
    );
  }

  Widget _buildReservationMeta(IconData icon, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: _brandColor, size: 15),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReservationForm(
    _ReservationRequest request, {
    bool appendIfNew = false,
  }) async {
    final updatedRequest = await Navigator.of(context).push<_ReservationRequest>(
      MaterialPageRoute(
        builder: (_) => _ReservationFormPage(
          request: request,
          menuItems: _menuItems,
        ),
      ),
    );

    if (!mounted || updatedRequest == null) return;

    setState(() {
      if (appendIfNew) {
        _reservationRequests.add(updatedRequest);
      } else {
        final index = _reservationRequests.indexWhere(
          (item) =>
              identical(item, request) ||
              (item.customerName == request.customerName &&
                  item.timeLabel == request.timeLabel),
        );
        if (index >= 0) {
          _reservationRequests[index] = updatedRequest;
        }
      }
      _reservationStatusTab = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xác nhận lịch đặt bàn thành công.')),
    );
  }

  void _showProcessedReservationInfo(_ReservationRequest request) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4C8BE),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Thông tin đặt bàn',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close, color: _textMuted),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F4F8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInfoRow('Người đặt', request.customerName),
                _buildInfoRow('Số điện thoại', request.phoneNumber ?? 'Chưa có'),
                _buildInfoRow('Thời gian', request.timeLabel),
                _buildInfoRow('Số khách', '${request.guestCount} khách'),
                _buildInfoRow('Bàn đã gán', request.tableNumber),
                _buildInfoRow('Món đặt trước', request.detailLabel),
                if (request.highlightItems != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.highlightItems!,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                if (request.highlightTotal != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Tổng tiền',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatCurrency(request.highlightTotal!),
                        style: const TextStyle(
                          color: _brandColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishImage(String imageUrl, {required double size, double radius = 12}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: const Color(0xFFE8EEF5),
          child: const Icon(Icons.restaurant, color: _textMuted),
        ),
      ),
    );
  }

  Widget _buildCircularDishThumb(String imageUrl, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFE8EEF5),
            child: const Icon(Icons.restaurant, color: _textMuted, size: 12),
          ),
        ),
      ),
    );
  }
}

class _ReservationFormPage extends StatefulWidget {
  const _ReservationFormPage({
    required this.request,
    required this.menuItems,
  });

  final _ReservationRequest request;
  final List<_MenuItem> menuItems;

  @override
  State<_ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<_ReservationFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _tableController;
  late final List<String> _tableOptions;
  late final List<int> _formQuantities;
  late String _selectedTable;

  final List<String> _timeSlots = const [
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
  ];
  final List<String> _foodCategories = const [
    'Khai vị',
    'Món chính',
    'Tráng miệng',
    'Đồ uống',
  ];

  String _selectedTime = '18:30';
  int _selectedFoodCategoryIndex = 0;

  int get _selectedDishCount =>
      _formQuantities.fold<int>(0, (total, quantity) => total + quantity);

  int get _selectedTotal {
    var total = 0;
    for (var i = 0; i < widget.menuItems.length; i++) {
      total += widget.menuItems[i].price * _formQuantities[i];
    }
    return total;
  }

  List<String> get _selectedDishNames {
    final names = <String>[];
    for (var i = 0; i < widget.menuItems.length; i++) {
      if (_formQuantities[i] > 0) {
        names.add('${widget.menuItems[i].name} x${_formQuantities[i]}');
      }
    }
    return names;
  }

  @override
  void initState() {
    super.initState();
    final request = widget.request;
    _nameController = TextEditingController(text: request.customerName);
    _phoneController = TextEditingController(text: request.phoneNumber ?? '');
    final initialTable =
        request.tableNumber == 'Chưa chọn bàn' ? 'Bàn 12' : request.tableNumber;
    _tableOptions = List<String>.generate(
      12,
      (index) => 'Bàn ${(index + 1).toString().padLeft(2, '0')}',
    );
    if (!_tableOptions.contains(initialTable)) {
      _tableOptions.add(initialTable);
    }
    _selectedTable = initialTable;
    _tableController = TextEditingController(text: _selectedTable);

    final requestTime = request.timeLabel.split('•').first.trim();
    if (_timeSlots.contains(requestTime)) {
      _selectedTime = requestTime;
    }

    _formQuantities = List<int>.filled(widget.menuItems.length, 0);
    if ((request.highlightTotal ?? 0) > 0 && widget.menuItems.isNotEmpty) {
      _formQuantities[0] = 1;
      if (widget.menuItems.length > 1) _formQuantities[1] = 1;
      if (widget.menuItems.length > 2) _formQuantities[2] = 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                _buildFormHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabeledInput(
                          label: 'Tên người đặt',
                          hint: 'Nhập họ và tên khách hàng...',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 10),
                        _buildLabeledInput(
                          label: 'Số điện thoại',
                          hint: 'Nhập số điện thoại khách hàng',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildReservationInfoCard(
                                title: 'Bàn của bạn',
                                value: _tableController.text,
                                subtitle: '${widget.request.guestCount} người',
                                icon: Icons.table_restaurant_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildReservationInfoCard(
                                title: 'Tổng món',
                                value: _selectedDishCount.toString().padLeft(2, '0'),
                                subtitle: _selectedDishCount > 0
                                    ? 'Đã chọn thực đơn'
                                    : 'Chưa chọn món',
                                icon: Icons.restaurant_menu,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildTableOptionField(),
                        const SizedBox(height: 12),
                        _buildCalendarCard(),
                        const SizedBox(height: 12),
                        _buildSmallTitle(Icons.schedule, 'Chọn khung giờ'),
                        const SizedBox(height: 8),
                        _buildTimeSlots(),
                        const SizedBox(height: 14),
                        _buildPreOrderHeader(),
                        const SizedBox(height: 8),
                        _buildFoodCategoryChips(),
                        const SizedBox(height: 10),
                        ...widget.menuItems
                            .asMap()
                            .entries
                            .take(3)
                            .map((entry) => _buildPreOrderFoodCard(entry.key, entry.value)),
                        const SizedBox(height: 10),
                        _buildReservationDetailBox(),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brandColor,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: _brandColor.withOpacity(0.25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _submitReservation,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Xác nhận lịch',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildFormHeader() {
    return Container(
      height: 52,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, color: _brandColor, size: 21),
          ),
          const Expanded(
            child: Text(
              'Đặt lịch trước',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _brandColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLabeledInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8DCD8)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFB0B7C3), fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableOptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bàn phục vụ',
          style: TextStyle(
            color: _textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8DCD8)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTable,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: Colors.white,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: _textMuted,
                size: 20,
              ),
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              items: _tableOptions.map((table) {
                return DropdownMenuItem<String>(
                  value: table,
                  child: Text(table),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedTable = value;
                  _tableController.text = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReservationInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8DCD8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _brandColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final days = [
      '26',
      '27',
      '28',
      '29',
      '30',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8DCD8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Tháng 10, 2023',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              _buildTinyCircleIcon(Icons.chevron_left),
              const SizedBox(width: 6),
              _buildTinyCircleIcon(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _CalendarWeekday('T2'),
              _CalendarWeekday('T3'),
              _CalendarWeekday('T4'),
              _CalendarWeekday('T5'),
              _CalendarWeekday('T6'),
              _CalendarWeekday('T7'),
              _CalendarWeekday('CN'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final label = days[index];
              final isSelected = label == '5';
              final isMuted = index < 5;
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? _brandColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isMuted
                            ? const Color(0xFFC9CDD5)
                            : _textPrimary,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTinyCircleIcon(IconData icon) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E3EA)),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 13, color: _textMuted),
    );
  }

  Widget _buildSmallTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: _brandColor, size: 15),
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _timeSlots.map((slot) {
        final isSelected = _selectedTime == slot;
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _selectedTime = slot),
          child: Container(
            width: 78,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFE4DC) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? _brandColor : const Color(0xFFE8DCD8),
              ),
            ),
            child: Text(
              slot,
              style: TextStyle(
                color: isSelected ? _brandColor : _textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreOrderHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Chọn món ăn đặt trước',
            style: TextStyle(
              color: _textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _brandSoft,
            borderRadius: BorderRadius.circular(99),
          ),
          child: const Text(
            'Khuyên dùng',
            style: TextStyle(
              color: _brandColor,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_foodCategories.length, (index) {
          final isActive = _selectedFoodCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(99),
              onTap: () => setState(() => _selectedFoodCategoryIndex = index),
              child: Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? _brandColor : Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isActive ? _brandColor : const Color(0xFFE8DCD8),
                  ),
                ),
                child: Text(
                  _foodCategories[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : _textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPreOrderFoodCard(int index, _MenuItem item) {
    final quantity = _formQuantities[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8DCD8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.network(
              item.imageUrl,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 58,
                height: 58,
                color: const Color(0xFFE8EEF5),
                child: const Icon(Icons.restaurant, color: _textMuted),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(item.price),
                  style: const TextStyle(
                    color: _brandColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (quantity == 0)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _brandColor,
                side: BorderSide(color: _brandColor.withOpacity(0.35)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(68, 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => setState(() => _formQuantities[index] = 1),
              icon: const Icon(Icons.add, size: 12),
              label: const Text(
                'THÊM',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
              ),
            )
          else
            Container(
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26),
                    onPressed: () => setState(() => _formQuantities[index]--),
                    icon: const Icon(Icons.remove, size: 13, color: _brandColor),
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26),
                    onPressed: () => setState(() => _formQuantities[index]++),
                    icon: const Icon(Icons.add, size: 13, color: _brandColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReservationDetailBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHI TIẾT ĐẶT TRƯỚC',
            style: TextStyle(
              color: _textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Thứ Năm, 05/10 lúc $_selectedTime',
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                'Thay đổi',
                style: TextStyle(
                  color: _brandColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDishCount > 0
                      ? '${_selectedDishCount.toString().padLeft(2, '0')} món ăn đã chọn'
                      : 'Chưa có món đặt trước',
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatCurrency(_selectedTotal),
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitReservation() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final table = _tableController.text.trim();

    if (name.isEmpty || phone.isEmpty || table.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ tên, số điện thoại và bàn.'),
        ),
      );
      return;
    }

    final dishNames = _selectedDishNames;
    final updatedRequest = widget.request.copyWith(
      customerName: name,
      phoneNumber: phone,
      timeLabel: '$_selectedTime • Hôm nay',
      tableNumber: table,
      detailLabel: _selectedDishCount > 0
          ? '${_selectedDishCount.toString().padLeft(2, '0')} món đặt trước'
          : 'Chưa đặt món',
      statusLabel: 'Đã xử lý',
      statusColor: const Color(0xFFEAF8EE),
      statusTextColor: const Color(0xFF208C44),
      highlightTitle: _selectedDishCount > 0 ? 'Món đã xác nhận:' : 'Ghi chú:',
      highlightItems: _selectedDishCount > 0
          ? dishNames.join(', ')
          : 'Lịch đặt bàn đã được xác nhận bởi nhân viên.',
      highlightTotal: _selectedTotal,
      isProcessed: true,
    );

    Navigator.pop(context, updatedRequest);
  }
}

class _CalendarWeekday extends StatelessWidget {
  const _CalendarWeekday(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _textMuted,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.name,
    required this.description,
    required this.note,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  final String name;
  final String description;
  final String note;
  final String category;
  final int price;
  final String imageUrl;
}

class _ReservationRequest {
  const _ReservationRequest({
    required this.customerName,
    required this.timeLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.statusTextColor,
    required this.guestCount,
    required this.detailLabel,
    required this.tableNumber,
    this.phoneNumber,
    this.highlightTitle,
    this.highlightItems,
    this.highlightTotal,
    this.isProcessed = false,
  });

  final String customerName;
  final String timeLabel;
  final String statusLabel;
  final Color statusColor;
  final Color statusTextColor;
  final int guestCount;
  final String detailLabel;
  final String tableNumber;
  final String? phoneNumber;
  final String? highlightTitle;
  final String? highlightItems;
  final int? highlightTotal;
  final bool isProcessed;

  _ReservationRequest copyWith({
    String? customerName,
    String? timeLabel,
    String? statusLabel,
    Color? statusColor,
    Color? statusTextColor,
    int? guestCount,
    String? detailLabel,
    String? tableNumber,
    String? phoneNumber,
    String? highlightTitle,
    String? highlightItems,
    int? highlightTotal,
    bool? isProcessed,
  }) {
    return _ReservationRequest(
      customerName: customerName ?? this.customerName,
      timeLabel: timeLabel ?? this.timeLabel,
      statusLabel: statusLabel ?? this.statusLabel,
      statusColor: statusColor ?? this.statusColor,
      statusTextColor: statusTextColor ?? this.statusTextColor,
      guestCount: guestCount ?? this.guestCount,
      detailLabel: detailLabel ?? this.detailLabel,
      tableNumber: tableNumber ?? this.tableNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      highlightTitle: highlightTitle ?? this.highlightTitle,
      highlightItems: highlightItems ?? this.highlightItems,
      highlightTotal: highlightTotal ?? this.highlightTotal,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}

String _formatCurrency(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }

  return '${buffer}đ';
}

