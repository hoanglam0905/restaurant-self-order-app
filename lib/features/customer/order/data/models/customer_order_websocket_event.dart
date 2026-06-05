enum CustomerOrderWebSocketEventType {
  newOrder,
  orderStatusUpdated,
  orderItemStatusUpdated,
  paymentStatusUpdated,
  paymentStatusReset,
  unknown,
}

class CustomerOrderWebSocketEvent {
  const CustomerOrderWebSocketEvent({
    required this.type,
    this.orderId,
    this.tableNumber,
    this.orderStatus,
    this.paymentStatus,
    this.dishId,
    this.itemStatus,
    this.dishName,
    this.quantity,
    this.notes,
    this.price,
  });

  final CustomerOrderWebSocketEventType type;
  final int? orderId;
  final int? tableNumber;
  final String? orderStatus;
  final String? paymentStatus;
  final int? dishId;
  final String? itemStatus;
  final String? dishName;
  final int? quantity;
  final String? notes;
  final double? price;

  bool get isOrderUpdate =>
      type == CustomerOrderWebSocketEventType.newOrder ||
      type == CustomerOrderWebSocketEventType.orderStatusUpdated ||
      type == CustomerOrderWebSocketEventType.orderItemStatusUpdated ||
      type == CustomerOrderWebSocketEventType.paymentStatusUpdated ||
      type == CustomerOrderWebSocketEventType.paymentStatusReset;

  factory CustomerOrderWebSocketEvent.fromJson(Map<String, dynamic> json) {
    final typeValue = json['type']?.toString();
    return switch (typeValue) {
      'NEW_ORDER' => _fromOrderPayload(
        CustomerOrderWebSocketEventType.newOrder,
        json['order'],
      ),
      'ORDER_STATUS_UPDATED' => _fromOrderPayload(
        CustomerOrderWebSocketEventType.orderStatusUpdated,
        json['order'],
      ),
      'ORDER_ITEM_STATUS_UPDATED' => _fromItemPayload(json['item']),
      'PAYMENT_STATUS_UPDATED' => _fromPaymentPayload(
        CustomerOrderWebSocketEventType.paymentStatusUpdated,
        json,
      ),
      'PAYMENT_STATUS_RESET' => _fromPaymentPayload(
        CustomerOrderWebSocketEventType.paymentStatusReset,
        json,
      ),
      _ => const CustomerOrderWebSocketEvent(
        type: CustomerOrderWebSocketEventType.unknown,
      ),
    };
  }

  static CustomerOrderWebSocketEvent _fromOrderPayload(
    CustomerOrderWebSocketEventType type,
    dynamic payload,
  ) {
    final order = payload is Map<String, dynamic>
        ? payload
        : <String, dynamic>{};
    return CustomerOrderWebSocketEvent(
      type: type,
      orderId: _intValue(order['orderId']),
      tableNumber: _intValue(order['tableNumber']),
      orderStatus: order['status']?.toString(),
      paymentStatus: order['paymentStatus']?.toString(),
    );
  }

  static CustomerOrderWebSocketEvent _fromItemPayload(dynamic payload) {
    final item = payload is Map<String, dynamic>
        ? payload
        : <String, dynamic>{};
    return CustomerOrderWebSocketEvent(
      type: CustomerOrderWebSocketEventType.orderItemStatusUpdated,
      orderId: _intValue(item['orderId']),
      tableNumber: _intValue(item['tableNumber']),
      dishId: _intValue(item['dishId']),
      itemStatus: item['status']?.toString(),
      dishName: item['dishName']?.toString(),
      quantity: _intValue(item['quantity']),
      notes: item['notes']?.toString(),
      price: (item['price'] as num?)?.toDouble(),
    );
  }

  static CustomerOrderWebSocketEvent _fromPaymentPayload(
    CustomerOrderWebSocketEventType type,
    Map<String, dynamic> payload,
  ) {
    return CustomerOrderWebSocketEvent(
      type: type,
      orderId: _intValue(payload['orderId']),
      tableNumber: _intValue(payload['tableNumber']),
      paymentStatus: payload['paymentStatus']?.toString(),
    );
  }

  static int? _intValue(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }
}
