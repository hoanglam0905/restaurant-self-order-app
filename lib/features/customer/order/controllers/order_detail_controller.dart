import 'dart:async';

import 'package:get/get.dart';

import '../../../../../core/storage/auth_session_storage.dart';
import '../data/models/customer_order_websocket_event.dart';
import '../data/models/order_detail_model.dart';
import '../data/models/order_item_model.dart';
import '../data/services/customer_order_websocket_service.dart';
import '../data/services/order_detail_service.dart';
import '../data/services/order_receipt_service.dart';

enum CustomerPaymentMethod {
  cash('CASH', 'Tiền mặt'),
  card('CARD', 'Chuyển khoản'),
  online('ONLINE', 'VNPay');

  const CustomerPaymentMethod(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class OrderDetailController extends GetxController {
  OrderDetailController({
    required OrderDetailService orderDetailService,
    required OrderReceiptService orderReceiptService,
    required this.orderId,
    CustomerOrderWebSocketService? webSocketService,
    AuthSessionStorage? authSessionStorage,
  }) : _orderDetailService = orderDetailService,
       _orderReceiptService = orderReceiptService,
       _webSocketService = webSocketService ?? CustomerOrderWebSocketService(),
       _authSessionStorage = authSessionStorage ?? AuthSessionStorage();

  final OrderDetailService _orderDetailService;
  final OrderReceiptService _orderReceiptService;
  final CustomerOrderWebSocketService _webSocketService;
  final AuthSessionStorage _authSessionStorage;
  final int orderId;

  StreamSubscription<CustomerOrderWebSocketEvent>? _realtimeSubscription;
  int? _connectedTableNumber;

  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;
  final RxBool isExportingReceipt = false.obs;
  final RxBool isApplyingPoints = false.obs;
  final RxInt cancellingDishId = 0.obs;
  final RxInt availablePoints = 0.obs;
  final RxInt enteredPointsToUse = 0.obs;
  final RxInt appliedPointsToUse = 0.obs;
  final RxDouble appliedDiscount = 0.0.obs;
  final RxDouble payableAmount = 0.0.obs;
  final RxString errorMessage = ''.obs;
  final RxString paymentMessage = ''.obs;
  final RxString receiptMessage = ''.obs;
  final RxString loyaltyMessage = ''.obs;
  final RxString vnpayPaymentUrl = ''.obs;
  final RxInt earnedPoints = 0.obs;
  final Rx<CustomerPaymentMethod> selectedPaymentMethod =
      CustomerPaymentMethod.online.obs;
  final Rxn<OrderDetailModel> order = Rxn<OrderDetailModel>();

  bool get isPaid => order.value?.paymentStatus.toUpperCase() == 'PAID';

  @override
  void onInit() {
    super.onInit();
    _realtimeSubscription = _webSocketService.events.listen(
      _handleRealtimeEvent,
    );
    refreshLoyaltyBalance();
    loadOrder();
  }

  Future<void> loadOrder({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final result = await _orderDetailService.getOrderDetail(orderId);
      order.value = result;
      payableAmount.value = _payableAmountFor(result);
      await _connectRealtime(result.tableNumber);
    } on OrderDetailException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Không thể tải đơn hàng.';
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
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
        pointsToUse: _pointsToUseForPayment,
      );
      paymentMessage.value = result.message;
      if (result.success && result.paymentStatus?.toUpperCase() == 'PAID') {
        await handlePaymentConfirmed();
      }
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

  Future<bool> requestStaffPayment(CustomerPaymentMethod method) async {
    final currentOrder = order.value;
    if (currentOrder == null) {
      paymentMessage.value = 'Không tìm thấy đơn hàng cần thanh toán.';
      return false;
    }

    if (currentOrder.paymentStatus.toUpperCase() == 'PAID') {
      paymentMessage.value = 'Đơn hàng này đã được thanh toán.';
      return true;
    }

    final customerSession = await _authSessionStorage.readCustomerSession();
    if (customerSession == null) {
      paymentMessage.value = 'Vui lòng đăng nhập trước khi yêu cầu thanh toán.';
      return false;
    }

    isProcessingPayment.value = true;
    paymentMessage.value = '';

    try {
      await _orderDetailService.processPayment(
        order: currentOrder,
        paymentMethod: method.apiValue,
        pointsToUse: _pointsToUseForPayment,
        confirmPayment: false,
      );
      await _orderDetailService.requestStaffPaymentCollection(
        order: currentOrder,
        customerId: customerSession.customerId,
        paymentMethodLabel: method.label,
      );
      paymentMessage.value =
          'Đã gửi yêu cầu thanh toán ${method.label.toLowerCase()} cho nhân viên.';
      await loadOrder();
      return true;
    } on OrderDetailException catch (error) {
      paymentMessage.value = error.message;
      return false;
    } catch (_) {
      paymentMessage.value = 'Không thể gửi yêu cầu thanh toán cho nhân viên.';
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
      final pointsToUse = _pointsToUseForPayment;
      if (pointsToUse > 0 && appliedPointsToUse.value != pointsToUse) {
        final applied = await applyPoints(pointsToUse);
        if (!applied) {
          paymentMessage.value = loyaltyMessage.value;
          return null;
        }
      }

      final result = await _orderDetailService.createVNPayPayment(
        currentOrder,
        pointsToUse: _pointsToUseForPayment,
      );
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

  Future<bool> applyPoints(int pointsToUse) async {
    updateEnteredPoints(pointsToUse);

    final currentOrder = order.value;
    if (currentOrder == null) {
      loyaltyMessage.value = 'Không tìm thấy đơn hàng cần áp điểm.';
      return false;
    }

    if (currentOrder.paymentStatus.toUpperCase() == 'PAID') {
      loyaltyMessage.value = 'Đơn hàng này đã được thanh toán.';
      return false;
    }

    if (pointsToUse <= 0) {
      loyaltyMessage.value = 'Vui lòng nhập số điểm muốn sử dụng.';
      return false;
    }

    if (availablePoints.value > 0 && pointsToUse > availablePoints.value) {
      loyaltyMessage.value = 'Số điểm sử dụng vượt quá điểm hiện có.';
      return false;
    }

    isApplyingPoints.value = true;
    loyaltyMessage.value = '';

    try {
      final result = await _orderDetailService.applyPoints(
        orderId: currentOrder.orderId,
        pointsToUse: pointsToUse,
      );
      appliedPointsToUse.value = pointsToUse;
      appliedDiscount.value = result.discount;
      payableAmount.value = result.payableAmount;
      loyaltyMessage.value = result.message;
      vnpayPaymentUrl.value = '';
      return result.success;
    } on OrderDetailException catch (error) {
      loyaltyMessage.value = error.message;
      return false;
    } catch (_) {
      loyaltyMessage.value = 'Không thể áp dụng điểm thưởng.';
      return false;
    } finally {
      isApplyingPoints.value = false;
    }
  }

  bool canCancelItem(OrderItemModel item) {
    return item.status.toUpperCase() == 'PENDING' && !isPaid;
  }

  Future<bool> cancelPendingItem(OrderItemModel item) async {
    if (!canCancelItem(item)) {
      errorMessage.value = 'Chỉ có thể hủy món đang chờ xử lý.';
      return false;
    }

    cancellingDishId.value = item.dishId;
    errorMessage.value = '';

    try {
      order.value = await _orderDetailService.cancelPendingOrderItem(
        orderId: orderId,
        dishId: item.dishId,
      );
      return true;
    } on OrderDetailException catch (error) {
      errorMessage.value = error.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Không thể hủy món đã chọn.';
      return false;
    } finally {
      cancellingDishId.value = 0;
    }
  }

  Future<String?> exportReceiptPdf() async {
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

  double payableAmountFor(OrderDetailModel order) => _payableAmountFor(order);

  double discountFor(OrderDetailModel order) => _discountFor(order);

  void updateEnteredPoints(int pointsToUse) {
    enteredPointsToUse.value = pointsToUse > 0 ? pointsToUse : 0;
    if (enteredPointsToUse.value != appliedPointsToUse.value) {
      vnpayPaymentUrl.value = '';
    }
  }

  Future<void> refreshLoyaltyBalance() async {
    try {
      final session = await _authSessionStorage.readCustomerSession();
      if (session == null) {
        return;
      }
      final balance = await _orderDetailService.getCustomerLoyaltyBalance(
        session.customerId,
      );
      availablePoints.value = balance.points;
    } catch (_) {
      availablePoints.value = 0;
    }
  }

  Future<int> handlePaymentConfirmed() async {
    final currentOrder = order.value;
    if (currentOrder != null) {
      earnedPoints.value = estimatedEarnedPointsFor(currentOrder);
    }
    await refreshLoyaltyBalance();
    return earnedPoints.value;
  }

  int estimatedEarnedPointsFor(OrderDetailModel order) {
    final payable = payableAmount.value > 0
        ? payableAmount.value
        : _payableAmountFor(order);
    return (payable ~/ 100000) * 1000;
  }

  int get _pointsToUseForPayment {
    if (enteredPointsToUse.value > 0) {
      return enteredPointsToUse.value;
    }
    return appliedPointsToUse.value;
  }

  double _discountFor(OrderDetailModel order) {
    if (appliedDiscount.value > 0) {
      return appliedDiscount.value;
    }
    final points = enteredPointsToUse.value;
    if (points <= 0) {
      return 0;
    }
    if (availablePoints.value > 0 && points > availablePoints.value) {
      return 0;
    }
    final discount = points.toDouble();
    return discount > order.totalAmount ? order.totalAmount : discount;
  }

  double _payableAmountFor(OrderDetailModel order) {
    final discount = _discountFor(order);
    if (discount <= 0) {
      return order.totalAmount;
    }
    final payable = order.totalAmount - discount;
    return payable < 0 ? 0 : payable;
  }

  Future<void> _connectRealtime(int tableNumber) async {
    if (tableNumber <= 0 || _connectedTableNumber == tableNumber) {
      return;
    }
    _connectedTableNumber = tableNumber;
    await _webSocketService.connect(tableNumber);
  }

  void _handleRealtimeEvent(CustomerOrderWebSocketEvent event) {
    if (event.orderId != orderId) {
      return;
    }

    final currentOrder = order.value;
    if (currentOrder == null) {
      unawaited(loadOrder(showLoading: false));
      return;
    }

    if (event.type == CustomerOrderWebSocketEventType.orderStatusUpdated ||
        event.type == CustomerOrderWebSocketEventType.newOrder ||
        event.type == CustomerOrderWebSocketEventType.paymentStatusUpdated ||
        event.type == CustomerOrderWebSocketEventType.paymentStatusReset) {
      order.value = currentOrder.copyWith(
        status: event.orderStatus,
        paymentStatus: event.paymentStatus,
      );
      if (event.paymentStatus?.toUpperCase() == 'PAID') {
        unawaited(handlePaymentConfirmed());
      }
      unawaited(loadOrder(showLoading: false));
      return;
    }

    if (event.type == CustomerOrderWebSocketEventType.orderItemStatusUpdated &&
        event.dishId != null) {
      final updatedItems = currentOrder.items.map((item) {
        if (item.dishId != event.dishId) {
          return item;
        }
        return item.copyWith(
          status: event.itemStatus,
          dishName: event.dishName,
          quantity: event.quantity,
          notes: event.notes,
          price: event.price,
        );
      }).toList();
      order.value = currentOrder.copyWith(items: updatedItems);
      unawaited(loadOrder(showLoading: false));
    }
  }

  @override
  void onClose() {
    _realtimeSubscription?.cancel();
    unawaited(_webSocketService.dispose());
    super.onClose();
  }
}
