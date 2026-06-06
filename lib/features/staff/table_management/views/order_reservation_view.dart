import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_cta_button.dart';
import '../data/models/order_dish_model.dart';
import '../data/models/staff_table_model.dart';
import '../data/models/table_order_model.dart';
import '../data/models/table_status.dart';
import '../data/services/dish_catalog_service.dart';
import '../data/services/order_graphql_service.dart';
import '../data/services/table_service.dart';
import '../controllers/reservation_approval_controller.dart';
import '../../../../core/network/api_client.dart';

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

  final TableService _tableService = TableService(ApiClient());
  final DishCatalogService _dishCatalogService = DishCatalogService();
  final OrderGraphqlService _orderGraphqlService = OrderGraphqlService();
  late final String _reservationControllerTag;
  late final ReservationApprovalController _reservationController;

  int _activeTopTab = 0;
  int _selectedTableIndex = 0;
  int _selectedCategoryIndex = 0;
  String _searchText = '';

  bool _isLoading = true;
  bool _isSubmittingOrder = false;
  String _errorMessage = '';

  List<StaffTableModel> _tables = <StaffTableModel>[];
  List<OrderDishModel> _dishes = <OrderDishModel>[];
  List<int> _quantities = <int>[];

  @override
  void initState() {
    super.initState();
    _reservationControllerTag = UniqueKey().toString();
    _reservationController = Get.put(
      ReservationApprovalController(tableService: _tableService),
      tag: _reservationControllerTag,
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    Get.delete<ReservationApprovalController>(tag: _reservationControllerTag);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await Future.wait([
        _tableService.getTables(),
        _dishCatalogService.getDishes(),
      ]);

      final tables = results[0] as List<StaffTableModel>;
      final dishes = (results[1] as List<OrderDishModel>)
          .where((dish) => dish.isAvailable)
          .toList();

      setState(() {
        _tables = tables;
        _dishes = dishes;
        _quantities = List<int>.filled(dishes.length, 0);

        if (_selectedTableIndex >= _tables.length) {
          _selectedTableIndex = 0;
        }

        if (_selectedCategoryIndex >= _categories.length) {
          _selectedCategoryIndex = 0;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<String> get _categories {
    final categorySet = <String>{};

    for (final dish in _dishes) {
      final category = dish.categoryName.trim();
      if (category.isNotEmpty) {
        categorySet.add(category);
      }
    }

    return <String>['Tất cả', ...categorySet.toList()..sort()];
  }

  Iterable<MapEntry<int, OrderDishModel>> get _filteredDishEntries {
    return _dishes.asMap().entries.where((entry) {
      final dish = entry.value;
      final categories = _categories;

      final matchesCategory =
          _selectedCategoryIndex == 0 ||
          dish.categoryName == categories[_selectedCategoryIndex];

      final normalizedSearch = _searchText.trim().toLowerCase();

      final matchesSearch =
          normalizedSearch.isEmpty ||
          dish.name.toLowerCase().contains(normalizedSearch) ||
          dish.description.toLowerCase().contains(normalizedSearch) ||
          dish.categoryName.toLowerCase().contains(normalizedSearch);

      return matchesCategory && matchesSearch;
    });
  }

  int get _selectedItemCount =>
      _quantities.fold<int>(0, (total, quantity) => total + quantity);

  int get _selectedTotal {
    var total = 0;

    for (var i = 0; i < _dishes.length; i++) {
      total += _dishes[i].price * _quantities[i];
    }

    return total;
  }

  List<MapEntry<int, OrderDishModel>> get _selectedDishEntries {
    return _dishes
        .asMap()
        .entries
        .where((entry) => _quantities[entry.key] > 0)
        .toList();
  }

  StaffTableModel? get _selectedTable {
    if (_tables.isEmpty) return null;
    if (_selectedTableIndex < 0 || _selectedTableIndex >= _tables.length) {
      return null;
    }

    return _tables[_selectedTableIndex];
  }

  Future<void> _submitOrder() async {
    if (_isSubmittingOrder) return;

    final selectedTable = _selectedTable;
    final selectedEntries = _selectedDishEntries;

    if (selectedTable == null) {
      _showSnackBar(message: 'Vui lòng chọn bàn.', isError: true);
      return;
    }

    if (selectedEntries.isEmpty) {
      _showSnackBar(message: 'Vui lòng chọn ít nhất 1 món.', isError: true);
      return;
    }

    setState(() {
      _isSubmittingOrder = true;
    });

    try {
      final orderItems = selectedEntries.map((entry) {
        final dish = entry.value;
        final quantity = _quantities[entry.key];

        return CreateOrderItemInput(
          dishId: dish.dishId,
          quantity: quantity,
          notes: '',
        );
      }).toList();

      final orderId = await _orderGraphqlService.createOrder(
        tableId: selectedTable.id,
        customerName: 'Khách tại ${selectedTable.tableNumber}',
        notes: 'Created by staff from OrderReservationView',
        items: orderItems,
      );

      if (!mounted) return;

      setState(() {
        for (var i = 0; i < _quantities.length; i++) {
          _quantities[i] = 0;
        }
      });

      _showSnackBar(
        message: 'Đã tạo đơn hàng #$orderId thành công.',
        isError: false,
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(message: e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingOrder = false;
        });
      }
    }
  }

  Future<void> _submitOrderFromSheet(BuildContext sheetContext) async {
    Navigator.pop(sheetContext);
    await _submitOrder();
  }

  void _showSnackBar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
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
                      _buildReservationUnavailableTab(),
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _isLoading ? null : _loadInitialData,
          ),
          const CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFFD4512A),
            child: Text(
              'ST',
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
            _buildTopTabButton('Đặt bàn', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTabButton(String label, int index) {
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
                      color: _brandColor.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : _textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _brandColor));
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (_tables.isEmpty) {
      return _buildEmptyState(
        icon: Icons.table_restaurant_outlined,
        title: 'Chưa có bàn',
        message: 'API /api/staff/tables chưa trả về bàn nào.',
      );
    }

    if (_dishes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.restaurant_menu_outlined,
        title: 'Chưa có món',
        message: 'API /api/dishes chưa trả về món khả dụng nào.',
      );
    }

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
                  trailing: TextButton.icon(
                    onPressed: _loadInitialData,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: _brandColor,
                      size: 15,
                    ),
                    label: const Text(
                      'Tải lại',
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
                if (_filteredDishEntries.isEmpty)
                  _buildEmptyMenuResult()
                else
                  ..._filteredDishEntries.map(
                    (entry) => _buildDishCard(entry.key, entry.value),
                  ),
              ],
            ),
          ),
        ),
        if (_selectedItemCount > 0) _buildOrderFooter(),
      ],
    );
  }

  Widget _buildReservationUnavailableTab() {
    return Obx(() {
      if (_reservationController.isLoading.value &&
          _reservationController.reservations.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: _brandColor),
        );
      }

      if (_reservationController.errorMessage.value.isNotEmpty &&
          _reservationController.reservations.isEmpty) {
        return _buildReservationErrorState();
      }

      if (_reservationController.reservations.isEmpty) {
        return _buildEmptyState(
          icon: Icons.event_available_outlined,
          title: 'Chưa có yêu cầu đặt bàn',
          message:
              'Các order có reservationTime từ GraphQL sẽ xuất hiện tại đây.',
        );
      }

      final pending = _reservationController.pendingReservations;
      final reviewed = _reservationController.reviewedReservations;

      return RefreshIndicator(
        onRefresh: _reservationController.loadReservations,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          children: [
            _buildReservationSummary(pending.length, reviewed.length),
            const SizedBox(height: 14),
            _buildSectionTitle(
              title: 'Yêu cầu chờ duyệt',
              trailing: TextButton.icon(
                onPressed: _reservationController.loadReservations,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: _brandColor,
                  size: 15,
                ),
                label: const Text(
                  'Tải lại',
                  style: TextStyle(
                    color: _brandColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (pending.isEmpty)
              _buildInlineEmptyReservation()
            else
              ...pending.map(_buildReservationRequestCard),
            if (reviewed.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionTitle(title: 'Đã xử lý gần đây'),
              const SizedBox(height: 10),
              ...reviewed.take(5).map(_buildReservationRequestCard),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildReservationErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 46, color: Colors.red[400]),
            const SizedBox(height: 10),
            Text(
              _reservationController.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            AppCtaButton(
              label: 'Thử lại',
              onPressed: _reservationController.loadReservations,
              backgroundColor: _brandColor,
              height: 42,
              borderRadius: 8,
              fontSize: 13,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationSummary(int pendingCount, int reviewedCount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DCD8)),
      ),
      child: Row(
        children: [
          _buildReservationMetric(
            label: 'Chờ duyệt',
            value: '$pendingCount',
            icon: Icons.pending_actions_rounded,
          ),
          Container(width: 1, height: 42, color: const Color(0xFFE8DCD8)),
          _buildReservationMetric(
            label: 'Đã xử lý',
            value: '$reviewedCount',
            icon: Icons.verified_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildReservationMetric({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _brandSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _brandColor, size: 18),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineEmptyReservation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DCD8)),
      ),
      child: const Text(
        'Không còn yêu cầu đặt bàn cần duyệt.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildReservationRequestCard(TableOrderModel order) {
    final isPending = order.status.toUpperCase() == 'SCHEDULED';
    final date = order.reservationTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DCD8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _brandSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_seat_rounded,
                  color: _brandColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName.isEmpty
                          ? 'Khách đặt bàn'
                          : order.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date == null
                          ? 'Chưa có thời gian'
                          : _formatDateTime(date),
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _buildReservationStatusPill(order.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildReservationInfo(
                icon: Icons.table_restaurant_outlined,
                label: 'Bàn',
                value: order.tableNumber.toString().padLeft(2, '0'),
              ),
              const SizedBox(width: 10),
              _buildReservationInfo(
                icon: Icons.restaurant_menu_rounded,
                label: 'Món đặt trước',
                value: '${order.items.length}',
              ),
              const SizedBox(width: 10),
              _buildReservationInfo(
                icon: Icons.receipt_long_rounded,
                label: 'Tạm tính',
                value: _formatCurrency(order.totalAmount),
              ),
            ],
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE8DCD8)),
            const SizedBox(height: 10),
            ...order.items.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (isPending) ...[
            const SizedBox(height: 14),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: AppCtaButton(
                      label: 'Từ chối',
                      onPressed: () => _rejectReservation(order),
                      enabled: !_reservationController.isActionLoading.value,
                      backgroundColor: const Color(0xFFF8EFEA),
                      foregroundColor: _brandColor,
                      height: 42,
                      borderRadius: 10,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppCtaButton(
                      label: 'Chấp nhận',
                      onPressed: () => _approveReservation(order),
                      enabled: !_reservationController.isActionLoading.value,
                      backgroundColor: _brandColor,
                      height: 42,
                      borderRadius: 10,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReservationInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _brandColor, size: 15),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationStatusPill(String status) {
    final normalized = status.toUpperCase();
    final label = switch (normalized) {
      'SCHEDULED' => 'Pending',
      'PENDING' => 'Accepted',
      'CANCELLED' || 'CANCELED' => 'Rejected',
      'COMPLETED' => 'Done',
      _ => status,
    };
    final color = switch (normalized) {
      'SCHEDULED' => const Color(0xFFC98100),
      'CANCELLED' || 'CANCELED' => const Color(0xFFC62828),
      'COMPLETED' => const Color(0xFF2E7D32),
      _ => _brandColor,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Future<void> _approveReservation(TableOrderModel order) async {
    final success = await _reservationController.approveReservation(order);
    if (!mounted) return;
    _showSnackBar(
      message: success
          ? 'Đã chấp nhận yêu cầu đặt bàn #${order.orderId}.'
          : _reservationController.errorMessage.value,
      isError: !success,
    );
  }

  Future<void> _rejectReservation(TableOrderModel order) async {
    final success = await _reservationController.rejectReservation(order);
    if (!mounted) return;
    _showSnackBar(
      message: success
          ? 'Đã từ chối yêu cầu đặt bàn #${order.orderId}.'
          : _reservationController.errorMessage.value,
      isError: !success,
    );
  }

  String _formatDateTime(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year} '
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 46, color: Colors.red[400]),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _loadInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _textMuted, size: 42),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMenuResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DCD8)),
      ),
      child: const Text(
        'Không tìm thấy món phù hợp.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
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
        ?trailing,
      ],
    );
  }

  Widget _buildTableSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tables.length, (index) {
          final table = _tables[index];
          final isActive = _selectedTableIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: () => setState(() => _selectedTableIndex = index),
              child: Container(
                height: 40,
                constraints: const BoxConstraints(minWidth: 68),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isActive ? _brandColor : Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isActive ? _brandColor : const Color(0xFFE3E8EF),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      table.tableNumber,
                      style: TextStyle(
                        color: isActive ? Colors.white : _textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _tableStatusLabel(table.status),
                      style: TextStyle(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.9)
                            : _textMuted,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildSearchField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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

  String _tableStatusLabel(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Trống';
      case TableStatus.occupied:
        return 'Có khách';
      case TableStatus.reserved:
        return 'Đặt trước';
    }
  }

  Widget _buildCategoryTabs() {
    final categories = _categories;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
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
                      categories[index],
                      style: TextStyle(
                        color: isActive ? _brandColor : _textPrimary,
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.w800
                            : FontWeight.w600,
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

  Widget _buildDishCard(int index, OrderDishModel dish) {
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
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDishImage(dish.imageUrl, size: 72, radius: 10),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
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
                  dish.description.isEmpty
                      ? dish.categoryName
                      : dish.description,
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
                  _formatCurrency(dish.price),
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
        _buildRoundCounterButton(icon: Icons.add, active: true, onTap: onPlus),
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
        child: Icon(icon, color: active ? Colors.white : _textMuted, size: 14),
      ),
    );
  }

  Widget _buildOrderFooter() {
    final selectedEntries = _selectedDishEntries;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _brandColor.withValues(alpha: 0.18)),
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
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: _brandColor.withValues(alpha: 0.26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSubmittingOrder ? null : _submitOrder,
              icon: _isSubmittingOrder
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle, size: 16),
              label: Text(
                _isSubmittingOrder ? 'ĐANG TẠO ĐƠN...' : 'XÁC NHẬN ĐƠN HÀNG',
                style: const TextStyle(
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
    if (_selectedDishEntries.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selectedEntries = _selectedDishEntries;
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
                        separatorBuilder: (_, _) => Divider(
                          color: _brandColor.withValues(alpha: 0.18),
                          height: 16,
                        ),
                        itemBuilder: (context, index) {
                          final entry = selectedEntries[index];
                          final dish = entry.value;
                          final quantity = _quantities[entry.key];

                          return Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _buildDishImage(
                                    dish.imageUrl,
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
                                      dish.name,
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
                                          Icons.category_outlined,
                                          color: _textMuted,
                                          size: 13,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            dish.categoryName,
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
                                    _formatCurrency(dish.price * quantity),
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
                              const Icon(
                                Icons.chair,
                                size: 15,
                                color: _textMuted,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _selectedTable == null
                                    ? 'Chưa chọn bàn'
                                    : 'Bàn ${_selectedTable!.tableNumber}',
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
                                  shadowColor: _brandColor.withValues(
                                    alpha: 0.25,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isSubmittingOrder
                                    ? null
                                    : () => _submitOrderFromSheet(sheetContext),
                                icon: _isSubmittingOrder
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.check_circle, size: 16),
                                label: Text(
                                  _isSubmittingOrder
                                      ? 'ĐANG TẠO ĐƠN...'
                                      : 'XÁC NHẬN ĐƠN HÀNG',
                                  style: const TextStyle(
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

  Widget _buildDishImage(
    String? imageUrl, {
    required double size,
    double radius = 12,
  }) {
    final url = imageUrl?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null || url.isEmpty
          ? _buildDishImageFallback(size)
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildDishImageFallback(size),
            ),
    );
  }

  Widget _buildDishImageFallback(double size) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFE8EEF5),
      child: const Icon(Icons.restaurant, color: _textMuted),
    );
  }

  Widget _buildCircularDishThumb(String? imageUrl, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildDishImage(imageUrl, size: size, radius: size / 2),
      ),
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

  return '$bufferđ';
}
