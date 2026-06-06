class TableOrderModel {
  const TableOrderModel({
    required this.orderId,
    required this.customerName,
    required this.tableNumber,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.items,
    this.reservationTime,
    this.orderDate,
  });

  final int orderId;
  final String customerName;
  final int tableNumber;
  final String status;
  final String paymentStatus;
  final int totalAmount;
  final List<TableOrderItemModel> items;
  final DateTime? reservationTime;
  final DateTime? orderDate;

  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';

  bool get isCancelled {
    final value = status.toUpperCase();
    return value == 'CANCELLED' || value == 'CANCELED';
  }

  bool get isFinished {
    final value = status.toUpperCase();
    return value == 'COMPLETED' || value == 'DONE' || value == 'FINISHED';
  }

  bool get isActive => !isPaid && !isCancelled && !isFinished;

  bool get isScheduledReservation {
    return reservationTime != null && status.toUpperCase() == 'SCHEDULED';
  }

  bool get areAllItemsCompletedOrCancelled {
    return items.every((item) => item.isCompletedOrCancelled);
  }

  bool get canReleaseTable {
    return isPaid && areAllItemsCompletedOrCancelled;
  }

  factory TableOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return TableOrderModel(
      orderId: _asInt(json['orderId']) ?? 0,
      customerName: (json['customerName'] ?? '').toString(),
      tableNumber: _asInt(json['tableNumber']) ?? 0,
      status: (json['status'] ?? '').toString(),
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
      totalAmount: _asInt(json['totalAmount']) ?? 0,
      reservationTime: _asDateTime(json['reservationTime']),
      orderDate: _asDateTime(json['orderDate']),
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => TableOrderItemModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const <TableOrderItemModel>[],
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  }
}

class TableOrderItemModel {
  const TableOrderItemModel({
    required this.dishId,
    required this.name,
    required this.quantity,
    required this.note,
    required this.status,
    this.unitPrice,
    this.totalPrice,
    this.imageUrl,
  });

  final int? dishId;
  final String name;
  final int quantity;
  final String note;
  final String status;
  final int? unitPrice;
  final int? totalPrice;
  final String? imageUrl;

  bool get isCompletedOrCancelled {
    final value = status.toUpperCase();
    return value == 'COMPLETED' || value == 'CANCELLED' || value == 'CANCELED';
  }

  factory TableOrderItemModel.fromJson(Map<String, dynamic> json) {
    final dishId = _asInt(json['dishId']);

    final dishData = json['dish'] is Map
        ? Map<String, dynamic>.from(json['dish'] as Map)
        : const <String, dynamic>{};

    final quantity = _asInt(json['quantity']) ?? 1;

    final unitPrice =
        _asInt(json['unitPrice']) ??
        _asInt(json['price']) ??
        _asInt(json['dishPrice']) ??
        _asInt(dishData['price']);

    final totalPrice =
        _asInt(json['totalPrice']) ??
        _asInt(json['amount']) ??
        _asInt(json['subtotal']) ??
        (unitPrice == null ? null : unitPrice * quantity);

    final name =
        (json['dishName'] ??
                json['name'] ??
                json['dishTitle'] ??
                dishData['name'] ??
                dishData['dishName'] ??
                '')
            .toString()
            .trim();

    return TableOrderItemModel(
      dishId: dishId,
      name: name.isEmpty ? 'Món #${dishId ?? ''}' : name,
      quantity: quantity,
      note: (json['notes'] ?? json['note'] ?? '').toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      imageUrl: (json['imageUrl'] ?? json['image'] ?? dishData['imageUrl'])
          ?.toString(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
