import 'dart:async';

import 'package:get/get.dart';

import '../../../../../core/storage/table_session_storage.dart';
import '../data/models/customer_order_websocket_event.dart';
import '../data/models/order_detail_model.dart';
import '../data/services/customer_order_websocket_service.dart';
import '../data/services/order_history_service.dart';
import '../data/services/order_receipt_service.dart';

class OrderHistoryController extends GetxController {
  OrderHistoryController({
    required OrderHistoryService orderHistoryService,
    required OrderReceiptService orderReceiptService,
    CustomerOrderWebSocketService? webSocketService,
    TableSessionStorage? tableSessionStorage,
  }) : _orderHistoryService = orderHistoryService,
       _orderReceiptService = orderReceiptService,
       _webSocketService = webSocketService ?? CustomerOrderWebSocketService(),
       _tableSessionStorage = tableSessionStorage ?? TableSessionStorage();

  final OrderHistoryService _orderHistoryService;
  final OrderReceiptService _orderReceiptService;
  final CustomerOrderWebSocketService _webSocketService;
  final TableSessionStorage _tableSessionStorage;

  StreamSubscription<CustomerOrderWebSocketEvent>? _realtimeSubscription;

  final RxBool isLoading = false.obs;
  final RxBool isExportingReceipt = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString receiptMessage = ''.obs;
  final RxList<OrderDetailModel> orders = <OrderDetailModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _realtimeSubscription = _webSocketService.events.listen(
      _handleRealtimeEvent,
    );
    _connectRealtime();
    loadHistory();
  }

  Future<void> loadHistory({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final result = await _orderHistoryService.getOrderHistory();
      orders.assignAll(result);
    } on OrderHistoryException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Không thể tải lịch sử đơn hàng.';
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<String?> exportReceiptPdf(int orderId) async {
    isExportingReceipt.value = true;
    receiptMessage.value = '';

    try {
      final filePath = await _orderReceiptService.exportReceiptPdf(orderId);
      receiptMessage.value = 'Đã xuất hóa đơn PDF.';
      return filePath;
    } on OrderReceiptException catch (error) {
      receiptMessage.value = error.message;
      return null;
    } catch (_) {
      receiptMessage.value = 'Không thể xuất hóa đơn PDF.';
      return null;
    } finally {
      isExportingReceipt.value = false;
    }
  }

  Map<String, List<OrderDetailModel>> get groupedOrders {
    final result = <String, List<OrderDetailModel>>{};
    final now = DateTime.now();

    for (final order in orders) {
      final date = order.orderDate ?? order.reservationTime ?? now;
      final key = _isSameDay(date, now)
          ? 'HÔM NAY'
          : '${date.day.toString().padLeft(2, '0')}/'
                '${date.month.toString().padLeft(2, '0')}/'
                '${date.year}';
      result.putIfAbsent(key, () => <OrderDetailModel>[]).add(order);
    }

    return result;
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  Future<void> _connectRealtime() async {
    final tableNumber = await _tableSessionStorage.readTableId();
    if (tableNumber == null || tableNumber <= 0) {
      return;
    }
    await _webSocketService.connect(tableNumber);
  }

  void _handleRealtimeEvent(CustomerOrderWebSocketEvent event) {
    if (!event.isOrderUpdate) {
      return;
    }
    unawaited(loadHistory(showLoading: false));
  }

  @override
  void onClose() {
    _realtimeSubscription?.cancel();
    unawaited(_webSocketService.dispose());
    super.onClose();
  }
}
