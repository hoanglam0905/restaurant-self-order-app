import 'package:get/get.dart';

import '../data/models/order_detail_model.dart';
import '../data/services/order_history_service.dart';

class OrderHistoryController extends GetxController {
  OrderHistoryController({required OrderHistoryService orderHistoryService})
    : _orderHistoryService = orderHistoryService;

  final OrderHistoryService _orderHistoryService;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<OrderDetailModel> orders = <OrderDetailModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _orderHistoryService.getOrderHistory();
      orders.assignAll(result);
    } on OrderHistoryException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Không thể tải lịch sử đơn hàng.';
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, List<OrderDetailModel>> get groupedOrders {
    final result = <String, List<OrderDetailModel>>{};
    final now = DateTime.now();

    for (final order in orders) {
      final date = order.reservationTime ?? now;
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
}
