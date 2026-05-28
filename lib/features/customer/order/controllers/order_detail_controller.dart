import 'package:get/get.dart';

import '../data/models/order_detail_model.dart';
import '../data/services/order_detail_service.dart';

class OrderDetailController extends GetxController {
  OrderDetailController({
    required OrderDetailService orderDetailService,
    required this.orderId,
  }) : _orderDetailService = orderDetailService;

  final OrderDetailService _orderDetailService;
  final int orderId;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<OrderDetailModel> order = Rxn<OrderDetailModel>();

  @override
  void onInit() {
    super.onInit();
    loadOrder();
  }

  Future<void> loadOrder() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      order.value = await _orderDetailService.getOrderDetail(orderId);
    } on OrderDetailException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Không thể tải đơn hàng.';
    } finally {
      isLoading.value = false;
    }
  }
}
