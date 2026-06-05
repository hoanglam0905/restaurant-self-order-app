import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_cta_button.dart';
import '../../../customer/order/data/models/order_detail_model.dart';
import '../../../customer/order/data/models/order_item_model.dart';
import '../../../customer/order/data/models/payment_process_result_model.dart';
import '../../../customer/order/data/models/vnpay_payment_model.dart';
import '../../../customer/order/data/services/order_receipt_service.dart';

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

enum _HistoryPaymentFilter {
  all('Tất cả thanh toán'),
  unpaid('Chưa thanh toán'),
  paid('Đã thanh toán');

  const _HistoryPaymentFilter(this.label);
  final String label;

  bool matches(OrderDetailModel order) {
    final status = order.paymentStatus.toUpperCase();
    return switch (this) {
      _HistoryPaymentFilter.all => true,
      _HistoryPaymentFilter.unpaid => status == 'UNPAID',
      _HistoryPaymentFilter.paid => status == 'PAID',
    };
  }
}

enum _StaffPaymentMethod {
  cash('CASH', 'Tiền mặt'),
  bankTransfer('CARD', 'Chuyển khoản'),
  vnpay('VNPAY', 'VNPay');

  const _StaffPaymentMethod(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

class _HistoryManagementViewState extends State<HistoryManagementView> {
  static const Color _primary = Color(0xFFAA3B20);
  static const Color _surface = Color(0xFFF9F6F7);

  late final _HistoryOrderApiService _historyOrderApiService;
  late final OrderReceiptService _orderReceiptService;

  List<OrderDetailModel> _orders = <OrderDetailModel>[];
  DateTime? _selectedDate;
  _HistorySortType _sortType = _HistorySortType.newest;
  _HistoryTimeFilter _timeFilter = _HistoryTimeFilter.all;
  _HistoryPaymentFilter _paymentFilter = _HistoryPaymentFilter.all;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _historyOrderApiService = _HistoryOrderApiService(apiClient: apiClient);
    _orderReceiptService = OrderReceiptService(apiClient);
    _loadOrders();
  }

  Future<void> _loadOrders({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final orders = await _historyOrderApiService.fetchOrders();

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _isLoading = false;
        _errorMessage = null;
      });
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _formatDioError(error);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải lịch sử đơn hàng: $error';
      });
    }
  }

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
              Expanded(child: _buildBody(groups)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Map<String, List<OrderDetailModel>> groups) {
    if (_isLoading && _orders.isEmpty) {
      return const _LoadingState();
    }

    if (_errorMessage != null && _orders.isEmpty) {
      return _ErrorState(message: _errorMessage!, onRetry: () => _loadOrders());
    }

    if (groups.isEmpty) {
      return RefreshIndicator(
        color: _primary,
        onRefresh: () => _loadOrders(showLoading: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 180), _EmptyState()],
        ),
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: () => _loadOrders(showLoading: false),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 94),
        children: [
          if (_errorMessage != null) ...[
            _InlineErrorBanner(
              message: _errorMessage!,
              onRetry: () => _loadOrders(),
            ),
            const SizedBox(height: 12),
          ],
          for (final entry in groups.entries) ...[
            _SectionLabel(text: entry.key),
            const SizedBox(height: 14),
            for (int i = 0; i < entry.value.length; i++) ...[
              _HistoryOrderCard(
                order: entry.value[i],
                onViewDetail: () => _openOrderDetail(entry.value[i]),
                onPrint: () => _showPrintDialog(entry.value[i]),
              ),
              if (i != entry.value.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
          ],
        ],
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
          _FilterPill(
            icon: Icons.payments_rounded,
            label: _paymentFilter.label,
            onTap: () => _showPaymentFilterSheet(context),
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
                style: TextStyle(color: _primary, fontWeight: FontWeight.w800),
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

      return _matchTimeFilter(date) && _paymentFilter.matches(order);
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

  void _showPaymentFilterSheet(BuildContext context) {
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
                  'Lọc theo thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              const Divider(height: 1),
              for (final filter in _HistoryPaymentFilter.values)
                ListTile(
                  title: Text(
                    filter.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: _paymentFilter == filter
                      ? const Icon(Icons.check, color: _primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _paymentFilter = filter;
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
            'Bạn có muốn xuất PDF bill #${order.orderId.toString().padLeft(4, '0')} không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              child: const Text('Xuất PDF'),
            ),
          ],
        );
      },
    );

    if (allow != true || !mounted) return;

    try {
      final filePath = await _orderReceiptService.exportReceiptPdf(
        order.orderId,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            filePath.isEmpty
                ? 'Đã xuất hóa đơn PDF.'
                : 'Đã xuất hóa đơn PDF: $filePath',
          ),
        ),
      );
    } on OrderReceiptException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xuất hóa đơn PDF.')),
      );
    }
  }

  Future<void> _openOrderDetail(OrderDetailModel order) async {
    OrderDetailModel detailOrder = order;

    try {
      detailOrder = await _historyOrderApiService.fetchOrderById(order.orderId);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không lấy được dữ liệu mới nhất, đang mở dữ liệu từ danh sách.',
          ),
        ),
      );
    }

    if (!mounted) return;

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _HistoryOrderDetailPage(
          order: detailOrder,
          historyOrderApiService: _historyOrderApiService,
          orderReceiptService: _orderReceiptService,
        ),
      ),
    );

    if (changed == true && mounted) {
      await _loadOrders(showLoading: false);
    }
  }

  DateTime _orderDate(OrderDetailModel order) {
    return order.orderDate ?? order.reservationTime ?? DateTime.now();
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

class _HistoryOrderApiService {
  const _HistoryOrderApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const String _ordersQuery = r'''
query GetOrders {
  orders {
    orderId
    customerName
    tableNumber
    status
    totalAmount
    paymentStatus
    reservationTime
    orderDate
    items {
      dishId
      dishName
      quantity
      price
      notes
      status
    }
  }
}
''';

  static const String _orderDetailQuery = r'''
query GetOrder($orderId: String!) {
  order(orderId: $orderId) {
    orderId
    customerName
    tableNumber
    status
    totalAmount
    paymentStatus
    reservationTime
    orderDate
    items {
      dishId
      dishName
      quantity
      price
      notes
      status
    }
  }
}
''';

  Future<List<OrderDetailModel>> fetchOrders() async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiConfig.graphqlUrl,
      data: <String, dynamic>{'query': _ordersQuery},
    );

    final body = response.data;
    if (body == null) {
      throw Exception('Server không trả về dữ liệu.');
    }

    _throwIfGraphQLError(body);

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Response GraphQL không hợp lệ.');
    }

    final rawOrders = data['orders'];
    if (rawOrders is! List) {
      return <OrderDetailModel>[];
    }

    return rawOrders
        .whereType<Map>()
        .map((raw) => _normalizeOrderJson(raw))
        .map(OrderDetailModel.fromJson)
        .toList();
  }

  Future<OrderDetailModel> fetchOrderById(int orderId) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiConfig.graphqlUrl,
      data: <String, dynamic>{
        'query': _orderDetailQuery,
        'variables': <String, dynamic>{'orderId': orderId.toString()},
      },
    );

    final body = response.data;
    if (body == null) {
      throw Exception('Server không trả về dữ liệu.');
    }

    _throwIfGraphQLError(body);

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Response GraphQL không hợp lệ.');
    }

    final rawOrder = data['order'];
    if (rawOrder is! Map) {
      throw Exception('Không tìm thấy đơn hàng #$orderId.');
    }

    return OrderDetailModel.fromJson(_normalizeOrderJson(rawOrder));
  }

  Future<PaymentProcessResultModel> processPayment({
    required OrderDetailModel order,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiClient.dio.post<dynamic>(
        '/payment/process',
        data: <String, dynamic>{
          'orderId': order.orderId,
          'paymentMethod': paymentMethod,
          'amount': order.totalAmount,
          'confirmPayment': true,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PaymentProcessResultModel.fromJson(data);
      }

      throw Exception('Không thể xử lý thanh toán.');
    } on DioException catch (error) {
      throw Exception(_paymentMessageFromDio(error));
    }
  }

  Future<VNPayPaymentModel> createVNPayPayment(OrderDetailModel order) async {
    try {
      final response = await _apiClient.dio.post<dynamic>(
        '/payment/vnpay',
        data: <String, dynamic>{
          'total': order.totalAmount.round(),
          'orderInfo': 'Payment for Order: ${order.orderId}',
          'returnUrl': '${ApiConfig.baseUrl}/payment/vnpay_payment',
          'orderId': order.orderId,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payment = VNPayPaymentModel.fromJson(data);
        if (payment.paymentUrl.trim().isEmpty) {
          throw Exception('Backend chưa trả link VNPay.');
        }
        return payment;
      }

      throw Exception('Không thể tạo thanh toán VNPay.');
    } on DioException catch (error) {
      throw Exception(_paymentMessageFromDio(error));
    }
  }

  Map<String, dynamic> _normalizeOrderJson(Map<dynamic, dynamic> raw) {
    final rawItems = raw['items'];

    return <String, dynamic>{
      'orderId': raw['orderId'],
      'customerName': raw['customerName'],
      'tableNumber': _toInt(raw['tableNumber']),
      'status': raw['status']?.toString() ?? 'PENDING',
      'totalAmount': _toDouble(raw['totalAmount']),
      'paymentStatus': raw['paymentStatus']?.toString() ?? 'UNPAID',
      'reservationTime': raw['reservationTime'],
      'orderDate': raw['orderDate'],
      'items': rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((item) => _normalizeOrderItemJson(item))
                .toList()
          : <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> _normalizeOrderItemJson(Map<dynamic, dynamic> raw) {
    return <String, dynamic>{
      'dishId': raw['dishId'],
      'dishName': raw['dishName'],
      'quantity': _toInt(raw['quantity']),
      'price': _toDouble(raw['price']),
      'notes': raw['notes'],
      'status': raw['status']?.toString() ?? 'PENDING',
    };
  }

  void _throwIfGraphQLError(Map<String, dynamic> body) {
    final errors = body['errors'];

    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;

      if (firstError is Map && firstError['message'] != null) {
        throw Exception(firstError['message'].toString());
      }

      throw Exception('GraphQL trả về lỗi.');
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _paymentMessageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thông tin thanh toán chưa hợp lệ.',
      401 => 'Vui lòng đăng nhập lại trước khi thanh toán.',
      403 => 'Bạn không có quyền thanh toán đơn hàng này.',
      404 => 'Không tìm thấy đơn hàng cần thanh toán.',
      409 => 'Đơn hàng này đã được thanh toán.',
      500 => 'Máy chủ chưa thể xử lý thanh toán.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
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
    final date = order.orderDate ?? order.reservationTime ?? DateTime.now();
    final timeLabel =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00';
    final orderCode = order.orderId.toString().padLeft(4, '0');
    final total = _calculateFinalTotal(order);

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
                        _formatCurrency(total),
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFAA3B20)),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFAA3B20),
              size: 38,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6D6868),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAA3B20),
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7CDA6)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFC47B1B),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF80510E),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Thử lại',
              style: TextStyle(
                color: Color(0xFFAA3B20),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryOrderDetailPage extends StatefulWidget {
  const _HistoryOrderDetailPage({
    required this.order,
    required this.historyOrderApiService,
    required this.orderReceiptService,
  });

  final OrderDetailModel order;
  final _HistoryOrderApiService historyOrderApiService;
  final OrderReceiptService orderReceiptService;

  @override
  State<_HistoryOrderDetailPage> createState() =>
      _HistoryOrderDetailPageState();
}

class _HistoryOrderDetailPageState extends State<_HistoryOrderDetailPage> {
  static const Color _primary = Color(0xFFAA3B20);

  late OrderDetailModel _order;
  _StaffPaymentMethod _paymentMethod = _StaffPaymentMethod.cash;
  bool _isProcessingPayment = false;
  bool _changed = false;
  String _paymentMessage = '';
  String _vnpayUrl = '';

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  bool get _isPaid => _order.paymentStatus.toUpperCase() == 'PAID';

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal(_order);
    final total = _calculateFinalTotal(_order);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F7),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
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
                    ..._order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DetailDishCard(item: item),
                      );
                    }),
                    const SizedBox(height: 8),
                    _buildSummary(subtotal: subtotal, total: total),
                    if (!_isPaid) ...[
                      const SizedBox(height: 16),
                      _buildPaymentPanel(),
                    ],
                    if (_paymentMessage.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _MessagePanel(
                        message: _paymentMessage,
                        isError: _paymentMessage.startsWith('Lỗi:'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    AppCtaButton(
                      label: 'Về trang chủ',
                      onPressed: () => Navigator.pop(context, _changed),
                      backgroundColor: const Color(0xFFB84F32),
                      height: 52,
                      borderRadius: 12,
                      fontSize: 16,
                      trailing: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppCtaButton(
                      label: 'In PDF',
                      onPressed: _showPrintDialog,
                      backgroundColor: const Color(0xFFD0D4DD),
                      foregroundColor: _primary,
                      height: 52,
                      borderRadius: 12,
                      fontSize: 16,
                      trailing: const Icon(
                        Icons.receipt_long_rounded,
                        color: _primary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8FA),
        border: Border(bottom: BorderSide(color: Color(0xFFE7D8D3))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context, _changed),
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
    );
  }

  Widget _buildSummary({required double subtotal, required double total}) {
    return Container(
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
                'Vị trí: Bàn ${_order.tableNumber.toString().padLeft(2, '0')}',
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
                  'Mã đơn: #BA-${_order.orderId.toString().padLeft(4, '0')}',
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
          _SummaryRow(label: 'Tạm tính', value: _formatCurrency(subtotal)),
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
    );
  }

  Widget _buildPaymentPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8CBA0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_rounded, color: _primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Hỗ trợ thanh toán',
                style: TextStyle(
                  color: Color(0xFF5C321E),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE6D6D1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_StaffPaymentMethod>(
                value: _paymentMethod,
                isExpanded: true,
                items: _StaffPaymentMethod.values.map((method) {
                  return DropdownMenuItem<_StaffPaymentMethod>(
                    value: method,
                    child: Text(
                      method.label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  );
                }).toList(),
                onChanged: _isProcessingPayment
                    ? null
                    : (method) {
                        if (method == null) return;
                        setState(() {
                          _paymentMethod = method;
                          _paymentMessage = '';
                        });
                      },
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppCtaButton(
            label: _paymentMethod == _StaffPaymentMethod.vnpay
                ? 'Tạo thanh toán VNPay'
                : _isProcessingPayment
                ? 'Đang xác nhận...'
                : 'Xác nhận đã nhận tiền',
            onPressed: _handlePaymentAction,
            enabled: !_isProcessingPayment,
            backgroundColor: const Color(0xFFAA3B20),
            height: 50,
            borderRadius: 10,
            fontSize: 15,
          ),
          if (_vnpayUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            AppCtaButton(
              label: 'Mở lại VNPay',
              onPressed: () => _openVNPay(_vnpayUrl),
              backgroundColor: const Color(0xFF234B8E),
              height: 48,
              borderRadius: 10,
              fontSize: 14,
              trailing: const Icon(
                Icons.open_in_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 10),
            AppCtaButton(
              label: 'Kiểm tra trạng thái thanh toán',
              onPressed: _refreshOrderStatus,
              enabled: !_isProcessingPayment,
              backgroundColor: const Color(0xFF4C7A38),
              height: 48,
              borderRadius: 10,
              fontSize: 14,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handlePaymentAction() async {
    if (_paymentMethod == _StaffPaymentMethod.vnpay) {
      await _createVNPayPayment();
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _paymentMessage = '';
    });

    try {
      final result = await widget.historyOrderApiService.processPayment(
        order: _order,
        paymentMethod: _paymentMethod.apiValue,
      );
      final latest = await widget.historyOrderApiService.fetchOrderById(
        _order.orderId,
      );
      if (!mounted) return;

      setState(() {
        _order = latest;
        _changed = true;
        _paymentMessage = result.message.isNotEmpty
            ? result.message
            : 'Đã xác nhận thanh toán.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _paymentMessage =
            'Lỗi: ${error.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  Future<void> _createVNPayPayment() async {
    setState(() {
      _isProcessingPayment = true;
      _paymentMessage = '';
      _vnpayUrl = '';
    });

    try {
      final payment = await widget.historyOrderApiService.createVNPayPayment(
        _order,
      );
      if (!mounted) return;

      setState(() {
        _vnpayUrl = payment.paymentUrl;
        _paymentMessage =
            'Đã tạo link VNPay. Sau khi khách thanh toán, bấm kiểm tra trạng thái.';
      });
      await _openVNPay(payment.paymentUrl);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _paymentMessage =
            'Lỗi: ${error.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  Future<void> _openVNPay(String paymentUrl) async {
    final uri = Uri.tryParse(paymentUrl);
    if (uri == null) {
      setState(() => _paymentMessage = 'Lỗi: Link VNPay không hợp lệ.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;

    setState(() {
      _paymentMessage = opened
          ? 'Đã mở VNPay. Sau khi khách thanh toán, bấm kiểm tra trạng thái.'
          : 'Lỗi: Không thể mở VNPay trên thiết bị này.';
    });
  }

  Future<void> _refreshOrderStatus() async {
    setState(() {
      _isProcessingPayment = true;
      _paymentMessage = '';
    });

    try {
      final latest = await widget.historyOrderApiService.fetchOrderById(
        _order.orderId,
      );
      if (!mounted) return;

      setState(() {
        _order = latest;
        _changed = true;
        _paymentMessage = latest.paymentStatus.toUpperCase() == 'PAID'
            ? 'Thanh toán đã hoàn tất.'
            : 'Đơn hàng vẫn chưa được thanh toán.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _paymentMessage =
            'Lỗi: ${error.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  Future<void> _showPrintDialog() async {
    final allow = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'In lại hóa đơn?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Bạn có muốn xuất PDF bill #${_order.orderId.toString().padLeft(4, '0')} không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              child: const Text('Xuất PDF'),
            ),
          ],
        );
      },
    );

    if (allow != true || !mounted) return;

    try {
      final filePath = await widget.orderReceiptService.exportReceiptPdf(
        _order.orderId,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            filePath.isEmpty
                ? 'Đã xuất hóa đơn PDF.'
                : 'Đã xuất hóa đơn PDF: $filePath',
          ),
        ),
      );
    } on OrderReceiptException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xuất hóa đơn PDF.')),
      );
    }
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFE9E6) : const Color(0xFFEAF7E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isError ? const Color(0xFFE2A19A) : const Color(0xFFAFD4A7),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? const Color(0xFF9E2F23) : const Color(0xFF2F6B28),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          height: 1.35,
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
                      : 'Ghi chú: Không có.',
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
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            ),
          ),
        );
      },
    );
  }
}

double _calculateSubtotal(OrderDetailModel order) {
  if (order.totalAmount > 0) {
    return order.totalAmount;
  }

  return order.items.fold<double>(0, (sum, item) => sum + item.subtotal);
}

double _calculateFinalTotal(OrderDetailModel order) {
  return _calculateSubtotal(order);
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

String _formatDioError(DioException error) {
  final statusCode = error.response?.statusCode;
  final responseData = error.response?.data;

  if (statusCode == 401 || statusCode == 403) {
    return 'Bạn chưa đăng nhập hoặc không có quyền xem lịch sử đơn hàng.';
  }

  if (responseData is Map && responseData['message'] != null) {
    return responseData['message'].toString();
  }

  if (responseData is String && responseData.isNotEmpty) {
    return responseData;
  }

  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return 'Kết nối tới server quá lâu. Vui lòng thử lại.';
  }

  if (error.type == DioExceptionType.connectionError) {
    return 'Không kết nối được tới server. Kiểm tra mạng hoặc backend.';
  }

  return 'Không thể tải lịch sử đơn hàng.';
}
