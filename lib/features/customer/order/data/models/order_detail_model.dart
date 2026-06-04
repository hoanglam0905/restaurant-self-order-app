import 'order_item_model.dart';

class OrderDetailModel {
  const OrderDetailModel({
    required this.orderId,
    required this.tableNumber,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    required this.items,
    this.customerName,
    this.reservationTime,
    this.orderDate,
  });

  final int orderId;
  final String? customerName;
  final int tableNumber;
  final String status;
  final double totalAmount;
  final String paymentStatus;
  final List<OrderItemModel> items;
  final DateTime? reservationTime;
  final DateTime? orderDate;

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      orderId: int.tryParse(json['orderId'].toString()) ?? 0,
      customerName: json['customerName'] as String?,
      tableNumber: (json['tableNumber'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'PENDING',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentStatus: json['paymentStatus'] as String? ?? 'UNPAID',
      items: (json['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(OrderItemModel.fromJson)
          .toList(),
      reservationTime: DateTime.tryParse(
        json['reservationTime']?.toString() ?? '',
      ),
      orderDate: DateTime.tryParse(json['orderDate']?.toString() ?? ''),
    );
  }

  OrderDetailModel copyWith({
    String? customerName,
    int? tableNumber,
    String? status,
    double? totalAmount,
    String? paymentStatus,
    List<OrderItemModel>? items,
    DateTime? reservationTime,
    DateTime? orderDate,
  }) {
    return OrderDetailModel(
      orderId: orderId,
      customerName: customerName ?? this.customerName,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      items: items ?? this.items,
      reservationTime: reservationTime ?? this.reservationTime,
      orderDate: orderDate ?? this.orderDate,
    );
  }
}
