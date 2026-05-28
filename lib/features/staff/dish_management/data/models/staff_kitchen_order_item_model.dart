class StaffKitchenOrderItemModel {
  const StaffKitchenOrderItemModel({
    this.dishId,
    required this.name,
    required this.quantity,
    this.note,
    this.status,
  });

  final int? dishId;
  final String name;
  final int quantity;
  final String? note;
  final String? status;

  factory StaffKitchenOrderItemModel.fromJson(Map<String, dynamic> json) {
    return StaffKitchenOrderItemModel(
      dishId: _parseInt(json['dishId']),
      name: (json['dishName'] ?? json['name'] ?? '').toString(),
      quantity: _parseInt(json['quantity']) ?? 0,
      note: json['notes']?.toString(),
      status: json['status']?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}