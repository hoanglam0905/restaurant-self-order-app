import 'order_item_request_model.dart';

class OrderRequestModel {
  const OrderRequestModel({
    required this.tableId,
    required this.items,
    this.customerName,
    this.notes,
  });

  final int tableId;
  final List<OrderItemRequestModel> items;
  final String? customerName;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'items': items.map((item) => item.toJson()).toList(),
      if (customerName != null && customerName!.trim().isNotEmpty)
        'customerName': customerName!.trim(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}
