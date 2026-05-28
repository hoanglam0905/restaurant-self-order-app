import 'package:get/get.dart';
import '../data/models/staff_kitchen_order_model.dart';
import '../data/services/kitchen_service.dart';

class KitchenController extends GetxController {
  KitchenController({required KitchenService kitchenService}) : _kitchenService = kitchenService;

  final KitchenService _kitchenService;

  final RxList<StaffKitchenOrderModel> orders = <StaffKitchenOrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdatingStatus = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedStatus = 'Tất cả'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetchedOrders = await _kitchenService.getKitchenOrders();
      orders.assignAll(fetchedOrders);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  List<StaffKitchenOrderModel> get filteredOrders {
    final result = orders.where((order) {
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();

        final matchTable = order.tableNumber.toLowerCase().contains(query);
        final matchItem = order.items.any((item) {
          final matchName = item.name.toLowerCase().contains(query);
          final matchNote = item.note?.toLowerCase().contains(query) ?? false;
          return matchName || matchNote;
        });

        if (!matchTable && !matchItem) {
          return false;
        }
      }

      if (selectedStatus.value == 'Đang làm' && order.status != KitchenOrderStatus.inProgress) {
        return false;
      }

      if (selectedStatus.value == 'Chưa làm' && order.status != KitchenOrderStatus.pending) {
        return false;
      }

      if (selectedStatus.value == 'Hoàn tất' && order.status != KitchenOrderStatus.completed) {
        return false;
      }

      return true;
    }).toList();

    result.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return result;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void changeStatusFilter(String status) {
    selectedStatus.value = status;
  }

  Future<void> startOrder(StaffKitchenOrderModel order) async {
    if (isUpdatingStatus.value) return;

    isUpdatingStatus.value = true;
    errorMessage.value = '';

    try {
      for (final item in order.items) {
        if (item.dishId == null) continue;

        final currentItemStatus = item.status?.toUpperCase();

        if (currentItemStatus == null || currentItemStatus == 'PENDING') {
          await _kitchenService.updateOrderItemStatus(
            orderId: order.id,
            dishId: item.dishId!,
            status: 'PROCESSING',
          );
        }
      }

      await loadOrders();

      Get.snackbar(
        'Thành công',
        'Đơn đã chuyển sang Đang làm',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = e.toString();

      Get.snackbar(
        'Lỗi cập nhật đơn',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<void> completeOrder(StaffKitchenOrderModel order) async {
    if (isUpdatingStatus.value) return;

    isUpdatingStatus.value = true;
    errorMessage.value = '';

    try {
      for (final item in order.items) {
        if (item.dishId == null) continue;

        final currentItemStatus = item.status?.toUpperCase();

        // Trường hợp DB đang bị lệch:
        // ORDERS = PROCESSING nhưng ORDER_ITEMS vẫn PENDING.
        // Backend chỉ cho PENDING -> PROCESSING -> COMPLETED,
        // nên nếu item còn PENDING thì chuyển qua PROCESSING trước.
        if (currentItemStatus == null || currentItemStatus == 'PENDING') {
          await _kitchenService.updateOrderItemStatus(
            orderId: order.id,
            dishId: item.dishId!,
            status: 'PROCESSING',
          );
        }

        if (currentItemStatus != 'COMPLETED') {
          await _kitchenService.updateOrderItemStatus(
            orderId: order.id,
            dishId: item.dishId!,
            status: 'COMPLETED',
          );
        }
      }

      await loadOrders();

      Get.snackbar(
        'Thành công',
        'Đơn đã hoàn tất',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = e.toString();

      Get.snackbar(
        'Lỗi hoàn tất đơn',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isUpdatingStatus.value = false;
    }
  }
}