import 'package:get/get.dart';

import '../data/models/order_detail_model.dart';
import '../data/services/order_detail_service.dart';

enum CustomerPaymentMethod {
  cash('CASH', 'Tiền mặt'),
  card('CARD', 'Thẻ ngân hàng'),
  online('ONLINE', 'VNPay');

  const CustomerPaymentMethod(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class OrderDetailController extends GetxController {
  OrderDetailController({
    required OrderDetailService orderDetailService,
    required this.orderId,
  }) : _orderDetailService = orderDetailService;

  final OrderDetailService _orderDetailService;
  final int orderId;

  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString paymentMessage = ''.obs;
  final RxString vnpayPaymentUrl = ''.obs;
  final Rx<CustomerPaymentMethod> selectedPaymentMethod =
      CustomerPaymentMethod.online.obs;
  final Rxn<OrderDetailModel> order = Rxn<OrderDetailModel>();

  bool get isPaid => order.value?.paymentStatus.toUpperCase() == 'PAID';

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

  Future<bool> processPayment(CustomerPaymentMethod method) async {
    final currentOrder = order.value;
    if (currentOrder == null) {
      paymentMessage.value = 'Không tìm thấy đơn hàng cần thanh toán.';
      return false;
    }

    if (currentOrder.paymentStatus.toUpperCase() == 'PAID') {
      paymentMessage.value = 'Đơn hàng này đã được thanh toán.';
      return true;
    }

    isProcessingPayment.value = true;
    paymentMessage.value = '';

    try {
      final result = await _orderDetailService.processPayment(
        order: currentOrder,
        paymentMethod: method.apiValue,
      );
      paymentMessage.value = result.message;
      await loadOrder();
      return result.success;
    } on OrderDetailException catch (error) {
      paymentMessage.value = error.message;
      return false;
    } catch (_) {
      paymentMessage.value = 'Không thể xử lý thanh toán.';
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<String?> createVNPayPayment() async {
    final currentOrder = order.value;
    if (currentOrder == null) {
      paymentMessage.value = 'Không tìm thấy đơn hàng cần thanh toán.';
      return null;
    }

    if (currentOrder.paymentStatus.toUpperCase() == 'PAID') {
      paymentMessage.value = 'Đơn hàng này đã được thanh toán.';
      return null;
    }

    isProcessingPayment.value = true;
    paymentMessage.value = '';

    try {
      final result = await _orderDetailService.createVNPayPayment(currentOrder);
      vnpayPaymentUrl.value = result.paymentUrl;
      paymentMessage.value = result.message;
      return result.paymentUrl;
    } on OrderDetailException catch (error) {
      paymentMessage.value = error.message;
      return null;
    } catch (_) {
      paymentMessage.value = 'Không thể tạo thanh toán VNPay.';
      return null;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  void selectPaymentMethod(CustomerPaymentMethod method) {
    selectedPaymentMethod.value = method;
    if (method != CustomerPaymentMethod.online) {
      vnpayPaymentUrl.value = '';
    }
  }
}
