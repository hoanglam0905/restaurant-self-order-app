import 'package:get/get.dart';
import '../data/models/staff_kitchen_order_model.dart';
import '../data/services/kitchen_service.dart';

class KitchenController extends GetxController {
  KitchenController({required KitchenService kitchenService}) : _kitchenService = kitchenService;

  final KitchenService _kitchenService;

  final RxList<StaffKitchenOrderModel> orders = <StaffKitchenOrderModel>[].obs;
  final RxBool isLoading = false.obs;
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
    return orders.where((order) {
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!order.tableNumber.toLowerCase().contains(query) && !order.items.any((item) => item.name.toLowerCase().contains(query))) {
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
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void changeStatusFilter(String status) {
    selectedStatus.value = status;
  }

  void startOrder(StaffKitchenOrderModel order) {
    _updateOrderStatus(order.id, KitchenOrderStatus.inProgress);
  }

  void completeOrder(StaffKitchenOrderModel order) {
    _updateOrderStatus(order.id, KitchenOrderStatus.completed);
  }

  void _updateOrderStatus(int orderId, KitchenOrderStatus status) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    final updated = StaffKitchenOrderModel(
      id: orders[index].id,
      tableNumber: orders[index].tableNumber,
      items: orders[index].items,
      status: status,
      createdAt: orders[index].createdAt,
      note: orders[index].note,
      alertText: orders[index].alertText,
    );

    orders[index] = updated;
  }
}
