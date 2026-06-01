import 'package:flutter/material.dart';

class OrderReservationView extends StatefulWidget {
  const OrderReservationView({super.key});

  @override
  State<OrderReservationView> createState() => _OrderReservationViewState();
}

class _OrderReservationViewState extends State<OrderReservationView> {
  int _activeTopTab = 0;
  int _selectedTableIndex = 0;
  int _selectedCategoryIndex = 0;
  String _searchText = '';
  bool _showDetails = false;

  final List<String> _tables = const ['T-01', 'T-02', 'T-03', 'T-04', 'T-05'];
  final List<String> _categories = const [
    'Tất cả',
    'Khai vị',
    'Món chính',
    'Tráng miệng',
  ];

  final List<_MenuItem> _menuItems = const <_MenuItem>[
    _MenuItem(
      name: 'Cá Hồi Áp Chảo',
      description: 'Sốt bơ chanh & măng tây',
      category: 'Món chính',
      price: 285000,
      imageUrl:
          'https://images.unsplash.com/photo-1485921325833-c519f76c4927?auto=format&fit=crop&w=900&q=80',
    ),
    _MenuItem(
      name: 'Bò Wagyu Nướng',
      description: 'Nấm truffle & khoai tây',
      category: 'Món chính',
      price: 890000,
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=900&q=80',
    ),
    _MenuItem(
      name: 'Mousse Socola',
      description: 'Dâu rừng & vụn vàng',
      category: 'Tráng miệng',
      price: 145000,
      imageUrl:
          'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=900&q=80',
    ),
    _MenuItem(
      name: 'Salad Mùa Hè',
      description: 'Rau hữu cơ & sốt balsamic',
      category: 'Khai vị',
      price: 118000,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  late final Map<String, int> _quantities = <String, int>{
    for (final item in _menuItems) item.name: 0,
  };

  Iterable<_MenuItem> get _filteredItems {
    final selectedCategory = _categories[_selectedCategoryIndex];

    return _menuItems.where((item) {
      final matchCategory =
          selectedCategory == 'Tất cả' || item.category == selectedCategory;
      final matchSearch =
          _searchText.isEmpty ||
          item.name.toLowerCase().contains(_searchText.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchText.toLowerCase());

      return matchCategory && matchSearch;
    });
  }

  int get _totalDishCount {
    return _quantities.values.fold(0, (sum, count) => sum + count);
  }

  int get _totalPrice {
    var total = 0;
    for (final item in _menuItems) {
      total += (_quantities[item.name] ?? 0) * item.price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF6F7FB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTopTabs(),
            Expanded(
              child: _activeTopTab == 0 ? _buildOrderTab() : _buildReserveTab(),
            ),
            _buildBottomSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 8, 8, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE9EAF0)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF747B8A),
            ),
          ),
          const Expanded(
            child: Text(
              'Tạo đơn hàng/đặt bàn',
              style: TextStyle(
                color: Color(0xFFB63F1D),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF505767),
                  size: 20,
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC62828),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFFB84F32),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'JD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            _buildSegmentTab(label: 'Tạo đơn hàng', index: 0),
            _buildSegmentTab(label: 'Đặt bàn', index: 1, badge: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab({
    required String label,
    required int index,
    int? badge,
  }) {
    final isActive = _activeTopTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTopTab = index),
        child: Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFB63F1D) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF4D5563),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : const Color(0xFFC62828),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$badge',
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFFB63F1D)
                          : Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Bàn phục vụ',
                style: TextStyle(
                  color: Color(0xFF222938),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Tất cả',
                style: TextStyle(
                  color: Color(0xFFB63F1D),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _tables.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedTableIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTableIndex = index),
                child: Container(
                  width: 68,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFB63F1D) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFB63F1D)
                          : const Color(0xFFE0E4EC),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _tables[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF444B5A),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E8F0)),
          ),
          child: TextField(
            onChanged: (value) => setState(() => _searchText = value),
            decoration: const InputDecoration(
              icon: Icon(
                Icons.search_rounded,
                color: Color(0xFF7B8394),
                size: 18,
              ),
              hintText: 'Tìm món ăn hoặc đồ uống...',
              hintStyle: TextStyle(
                fontSize: 12,
                color: Color(0xFF8A92A2),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final isActive = _selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategoryIndex = index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _categories[index],
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFFB63F1D)
                            : const Color(0xFF565D6C),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: isActive ? 42 : 0,
                      height: 2,
                      color: const Color(0xFFB63F1D),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        ..._filteredItems.map((item) => _buildDishCard(item)),
      ],
    );
  }

  Widget _buildDishCard(_MenuItem item) {
    final quantity = _quantities[item.name] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAF1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.imageUrl,
              width: 82,
              height: 82,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) => Container(
                width: 82,
                height: 82,
                color: const Color(0xFFEAEFF7),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFF939BAA),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Color(0xFF1F2430),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Color(0xFF666D7B),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      _formatCurrency(item.price),
                      style: const TextStyle(
                        color: Color(0xFFB63F1D),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    _buildQuantityControl(item.name, quantity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(String key, int quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _buildCircleButton(
            icon: Icons.remove,
            onTap: () {
              if ((_quantities[key] ?? 0) == 0) return;
              setState(() {
                _quantities[key] = (_quantities[key] ?? 0) - 1;
              });
            },
            background: Colors.white,
            foreground: const Color(0xFF8D95A4),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2F3645),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _buildCircleButton(
            icon: Icons.add,
            onTap: () {
              setState(() {
                _quantities[key] = (_quantities[key] ?? 0) + 1;
              });
            },
            background: const Color(0xFFB63F1D),
            foreground: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color background,
    required Color foreground,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: foreground),
      ),
    );
  }

  Widget _buildReserveTab() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E9F1)),
        ),
        child: const Text(
          'Tab Đặt bàn sẽ được hoàn thiện ở bước tiếp theo.',
          style: TextStyle(
            color: Color(0xFF5E6674),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    final selectedItems = _menuItems
        .where((e) => (_quantities[e.name] ?? 0) > 0)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E9F1))),
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (_totalDishCount > 0)
                ...selectedItems.take(3).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFFF1F4FB),
                      child: Text(
                        item.name.substring(0, 1),
                        style: const TextStyle(
                          color: Color(0xFF505767),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                )
              else
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFF1F4FB),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 12,
                    color: Color(0xFF717A8C),
                  ),
                ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$_totalDishCount món',
                  style: const TextStyle(
                    color: Color(0xFF5D6574),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showDetails = !_showDetails),
                child: Text(
                  _showDetails
                      ? 'Ẩn chi tiết'
                      : 'Xem chi tiết ∧',
                  style: const TextStyle(
                    color: Color(0xFFB63F1D),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (_showDetails && selectedItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: selectedItems
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.name} x${_quantities[item.name]}',
                                style: const TextStyle(
                                  color: Color(0xFF505869),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              _formatCurrency(
                                item.price * (_quantities[item.name] ?? 0),
                              ),
                              style: const TextStyle(
                                color: Color(0xFF505869),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tổng cộng ($_totalDishCount món)',
                  style: const TextStyle(
                    color: Color(0xFF5D6574),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _formatCurrency(_totalPrice),
                style: const TextStyle(
                  color: Color(0xFFB63F1D),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 232,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _totalDishCount == 0 ? null : () {},
              icon: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 14,
              ),
              label: const Text(
                'XÁC NHẬN ĐƠN HÀNG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB63F1D),
                disabledBackgroundColor: const Color(0xFFBFC6D3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
}

class _MenuItem {
  const _MenuItem({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  final String name;
  final String description;
  final String category;
  final int price;
  final String imageUrl;
}

