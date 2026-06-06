import 'package:get/get.dart';

import '../data/models/table_order_model.dart';
import '../data/models/table_status.dart';
import '../data/services/table_service.dart';

class ReservationApprovalController extends GetxController {
  ReservationApprovalController({required TableService tableService})
    : _tableService = tableService;

  final TableService _tableService;

  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TableOrderModel> reservations = <TableOrderModel>[].obs;

  List<TableOrderModel> get pendingReservations {
    return reservations
        .where((order) => order.status.toUpperCase() == 'SCHEDULED')
        .toList();
  }

  List<TableOrderModel> get reviewedReservations {
    return reservations
        .where((order) => order.status.toUpperCase() != 'SCHEDULED')
        .toList();
  }

  int get pendingCount => pendingReservations.length;

  @override
  void onInit() {
    super.onInit();
    loadReservations();
  }

  Future<void> loadReservations() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final orders = await _tableService.getOrders();
      final reservationOrders =
          orders.where((order) => order.reservationTime != null).toList()
            ..sort((a, b) {
              final left = a.reservationTime ?? DateTime(0);
              final right = b.reservationTime ?? DateTime(0);
              return left.compareTo(right);
            });

      reservations.assignAll(reservationOrders);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> approveReservation(TableOrderModel order) async {
    return _updateReservationStatus(order: order, status: 'PENDING');
  }

  Future<bool> rejectReservation(TableOrderModel order) async {
    final updated = await _updateReservationStatus(
      order: order,
      status: 'CANCELLED',
      reloadAfterUpdate: false,
    );
    if (!updated) {
      return false;
    }

    try {
      await _tableService.updateTableStatus(
        tableId: order.tableNumber,
        status: TableStatus.available.toJson(),
      );
    } catch (_) {
      // The order has already been cancelled. Keep the primary action successful
      // and let the next table refresh reconcile status from the backend.
    }

    await loadReservations();
    return true;
  }

  Future<bool> _updateReservationStatus({
    required TableOrderModel order,
    required String status,
    bool reloadAfterUpdate = true,
  }) async {
    if (isActionLoading.value) {
      return false;
    }

    isActionLoading.value = true;
    errorMessage.value = '';

    try {
      await _tableService.updateOrderStatus(
        orderId: order.orderId,
        status: status,
      );
      if (reloadAfterUpdate) {
        await loadReservations();
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }
}
