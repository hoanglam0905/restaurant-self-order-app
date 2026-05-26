import '../models/staff_kitchen_order_item_model.dart';
import '../models/staff_kitchen_order_model.dart';

class KitchenService {
  Future<List<StaffKitchenOrderModel>> getKitchenOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return [
      StaffKitchenOrderModel(
        id: 1,
        tableNumber: 'T-08',
        status: KitchenOrderStatus.pending,
        createdAt: DateTime(2026, 5, 26, 14, 9),
        alertText: 'Thêm bánh mì',
        items: [
          StaffKitchenOrderItemModel(name: 'Bouillabaisse', quantity: 1, note: 'Thêm bánh mì'),
        ],
      ),
      StaffKitchenOrderModel(
        id: 2,
        tableNumber: 'T-01',
        status: KitchenOrderStatus.inProgress,
        createdAt: DateTime(2026, 5, 26, 14, 15),
        items: [
          StaffKitchenOrderItemModel(name: 'Salad Landaise', quantity: 1, note: 'ít dầu giấm'),
          StaffKitchenOrderItemModel(name: 'Ratatouille', quantity: 1),
        ],
      ),
      StaffKitchenOrderModel(
        id: 3,
        tableNumber: 'T-04',
        status: KitchenOrderStatus.pending,
        createdAt: DateTime(2026, 5, 26, 14, 22),
        alertText: 'Không hành, thêm sốt cam',
        items: [
          StaffKitchenOrderItemModel(name: 'Magret De Canard', quantity: 2, note: 'Không hành, thêm sốt cam'),
          StaffKitchenOrderItemModel(name: 'Soupe à l’Oignon', quantity: 1, note: 'Nóng hổi'),
        ],
      ),
      StaffKitchenOrderModel(
        id: 4,
        tableNumber: 'T-12',
        status: KitchenOrderStatus.inProgress,
        createdAt: DateTime(2026, 5, 26, 14, 25),
        items: [
          StaffKitchenOrderItemModel(name: 'Filet Mignon', quantity: 3, note: 'Medium Rare'),
        ],
      ),
    ];
  }
}
