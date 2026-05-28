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

  factory StaffKitchenOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    final parsedItems = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(StaffKitchenOrderItemModel.fromJson)
            .toList()
        : <StaffKitchenOrderItemModel>[];

    final tableNumber = _parseInt(json['tableNumber']);

    String? firstNote;
    for (final item in parsedItems) {
      if (item.note != null && item.note!.trim().isNotEmpty) {
        firstNote = item.note;
        break;
      }
    }

    return StaffKitchenOrderModel(
      id: _parseInt(json['orderId']) ?? 0,
      tableNumber: tableNumber == null ? 'T-??' : 'T-${tableNumber.toString().padLeft(2, '0')}',
      items: parsedItems,
      status: _statusFromApi(json['status']?.toString()),
      createdAt: _parseDateTime(json['reservationTime']),
      note: null,
      alertText: firstNote,
    );
  }

  static KitchenOrderStatus _statusFromApi(String? status) {
    switch (status?.toUpperCase()) {
      case 'PROCESSING':
      case 'IN_PROGRESS':
        return KitchenOrderStatus.inProgress;
      case 'COMPLETED':
        return KitchenOrderStatus.completed;
      case 'PENDING':
      case 'SCHEDULED':
      default:
        return KitchenOrderStatus.pending;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    final parsed = DateTime.tryParse(value.toString());
    return parsed ?? DateTime.now();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}