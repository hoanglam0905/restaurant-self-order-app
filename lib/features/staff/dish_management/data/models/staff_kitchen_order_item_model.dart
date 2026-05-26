class StaffKitchenOrderItemModel {
  const StaffKitchenOrderItemModel({
    required this.name,
    required this.quantity,
    this.note,
  });

  final String name;
  final int quantity;
  final String? note;
}
