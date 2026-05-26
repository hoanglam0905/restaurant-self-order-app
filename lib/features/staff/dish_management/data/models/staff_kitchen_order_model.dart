import 'staff_kitchen_order_item_model.dart';

enum KitchenOrderStatus { pending, inProgress, completed }

extension KitchenOrderStatusLabel on KitchenOrderStatus {
  String get label {
    switch (this) {
      case KitchenOrderStatus.pending:
        return 'CHƯA LÀM';
      case KitchenOrderStatus.inProgress:
        return 'ĐANG LÀM';
      case KitchenOrderStatus.completed:
        return 'HOÀN TẤT';
    }
  }

  int get badgeColorValue {
    switch (this) {
      case KitchenOrderStatus.pending:
        return 0xFFE4572E;
      case KitchenOrderStatus.inProgress:
        return 0xFF9E3A14;
      case KitchenOrderStatus.completed:
        return 0xFF2E7D32;
    }
  }
}

class StaffKitchenOrderModel {
  const StaffKitchenOrderModel({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.status,
    required this.createdAt,
    this.note,
    this.alertText,
  });

  final int id;
  final String tableNumber;
  final List<StaffKitchenOrderItemModel> items;
  final KitchenOrderStatus status;
  final DateTime createdAt;
  final String? note;
  final String? alertText;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
