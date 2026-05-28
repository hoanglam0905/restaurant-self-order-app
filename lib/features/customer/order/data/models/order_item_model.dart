class OrderItemModel {
  const OrderItemModel({
    required this.dishId,
    required this.quantity,
    required this.status,
    this.dishName,
    this.price = 0,
    this.notes,
  });

  final int dishId;
  final int quantity;
  final String status;
  final String? dishName;
  final double price;
  final String? notes;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      dishId: int.tryParse(json['dishId'].toString()) ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'PENDING',
      dishName: json['dishName'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
    );
  }

  double get subtotal => price * quantity;
}
