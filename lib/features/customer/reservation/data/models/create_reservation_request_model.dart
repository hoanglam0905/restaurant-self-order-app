import '../../../menu/data/models/order_item_request_model.dart';

class CreateReservationRequestModel {
  const CreateReservationRequestModel({
    required this.tableId,
    required this.reservationTime,
    required this.items,
    this.customerId,
    this.customerName,
    this.notes,
  });

  final int tableId;
  final DateTime reservationTime;
  final List<OrderItemRequestModel> items;
  final int? customerId;
  final String? customerName;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'items': items.map((item) => item.toJson()).toList(),
      'reservationTime': reservationTime.toIso8601String(),
      if (customerId != null) 'customerId': customerId,
      if (customerName != null && customerName!.trim().isNotEmpty)
        'customerName': customerName!.trim(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}
