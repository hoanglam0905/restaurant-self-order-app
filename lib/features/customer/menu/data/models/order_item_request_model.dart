class OrderItemRequestModel {
  const OrderItemRequestModel({
    required this.dishId,
    required this.quantity,
    this.notes,
  });

  final int dishId;
  final int quantity;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'dishId': dishId,
      'quantity': quantity,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}
