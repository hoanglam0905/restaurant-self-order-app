import 'package:get/get.dart';

import '../../../../../core/storage/auth_session_storage.dart';
import '../../../../../core/storage/table_session_storage.dart';
import '../../order/data/models/order_detail_model.dart';
import '../../order/data/services/order_history_service.dart';
import '../data/models/call_staff_request_model.dart';
import '../data/services/call_staff_order_lookup_service.dart';
import '../data/services/home_notification_service.dart';

class CallStaffController extends GetxController {
  CallStaffController({
    required HomeNotificationService notificationService,
    required OrderHistoryService orderHistoryService,
    required CallStaffOrderLookupService orderLookupService,
    AuthSessionStorage? authSessionStorage,
    TableSessionStorage? tableSessionStorage,
  }) : _notificationService = notificationService,
       _orderHistoryService = orderHistoryService,
       _orderLookupService = orderLookupService,
       _authSessionStorage = authSessionStorage ?? AuthSessionStorage(),
       _tableSessionStorage = tableSessionStorage ?? TableSessionStorage();

  final HomeNotificationService _notificationService;
  final OrderHistoryService _orderHistoryService;
  final CallStaffOrderLookupService _orderLookupService;
  final AuthSessionStorage _authSessionStorage;
  final TableSessionStorage _tableSessionStorage;

  final RxBool isSending = false.obs;
  final RxBool isResolvingTarget = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> get requiresGuestTableScan async {
    final customerSession = await _authSessionStorage.readCustomerSession();
    return customerSession == null;
  }

  Future<CallStaffTarget?> resolveTarget({int? scannedTableNumber}) async {
    isResolvingTarget.value = true;
    errorMessage.value = '';

    try {
      final customerSession = await _authSessionStorage.readCustomerSession();
      if (customerSession == null) {
        if (scannedTableNumber == null || scannedTableNumber <= 0) {
          errorMessage.value = 'Vui lòng quét QR bàn trước khi gọi nhân viên.';
          return null;
        }
        final order = await _orderLookupService.findLatestUnpaidOrderForTable(
          scannedTableNumber,
        );

        await _tableSessionStorage.saveTableSession(
          tableId: order.tableNumber,
          tableLabel: order.tableNumber.toString(),
        );

        return CallStaffTarget(
          tableNumber: order.tableNumber,
          customerId: order.customerId,
          orderId: order.orderId,
        );
      }

      final orders = await _orderHistoryService.getOrderHistory();
      final unpaidOrder = _latestUnpaidOrder(orders);
      if (unpaidOrder == null) {
        errorMessage.value =
            'Không tìm thấy đơn chưa thanh toán để xác định bàn.';
        return null;
      }

      await _tableSessionStorage.saveTableSession(
        tableId: unpaidOrder.tableNumber,
        tableLabel: unpaidOrder.tableNumber.toString(),
      );

      return CallStaffTarget(
        tableNumber: unpaidOrder.tableNumber,
        customerId: customerSession.customerId,
        orderId: unpaidOrder.orderId,
      );
    } on OrderHistoryException catch (error) {
      errorMessage.value = error.message;
      return null;
    } on CallStaffOrderLookupException catch (error) {
      errorMessage.value = error.message;
      return null;
    } catch (_) {
      errorMessage.value = 'Không thể xác định bàn gọi nhân viên.';
      return null;
    } finally {
      isResolvingTarget.value = false;
    }
  }

  Future<bool> callStaff({
    required CallStaffTarget target,
    required String requirement,
  }) async {
    if (target.tableNumber <= 0) {
      errorMessage.value = 'Không thể xác định bàn gọi nhân viên.';
      return false;
    }

    if (target.customerId <= 0) {
      errorMessage.value =
          'KhÃ´ng thá»ƒ xÃ¡c Ä‘á»‹nh khÃ¡ch cá»§a bÃ n gá»i nhÃ¢n viÃªn.';
      return false;
    }

    final normalizedRequirement = requirement.trim();
    final message = normalizedRequirement.isEmpty
        ? 'Khách cần nhân viên hỗ trợ tại bàn.'
        : normalizedRequirement;

    isSending.value = true;
    errorMessage.value = '';

    try {
      await _notificationService.callStaff(
        CallStaffRequestModel(
          tableNumber: target.tableNumber,
          customerId: target.customerId,
          orderId: target.orderId,
          additionalMessage: message,
        ),
      );
      return true;
    } on HomeNotificationException catch (error) {
      errorMessage.value = error.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Không thể gửi yêu cầu gọi nhân viên.';
      return false;
    } finally {
      isSending.value = false;
    }
  }

  OrderDetailModel? _latestUnpaidOrder(List<OrderDetailModel> orders) {
    final unpaidOrders = orders
        .where((order) => order.paymentStatus.toUpperCase() == 'UNPAID')
        .toList();
    if (unpaidOrders.isEmpty) {
      return null;
    }

    unpaidOrders.sort((left, right) {
      final leftDate = left.orderDate ?? left.reservationTime ?? DateTime(0);
      final rightDate = right.orderDate ?? right.reservationTime ?? DateTime(0);
      return rightDate.compareTo(leftDate);
    });
    return unpaidOrders.first;
  }
}

class CallStaffTarget {
  const CallStaffTarget({
    required this.tableNumber,
    required this.customerId,
    this.orderId,
  });

  final int tableNumber;
  final int customerId;
  final int? orderId;
}
