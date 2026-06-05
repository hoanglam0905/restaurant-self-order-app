import '../../../order/data/models/customer_order_websocket_event.dart';

enum CustomerNotificationKind { order, orderItem, payment }

class CustomerNotificationModel {
  const CustomerNotificationModel({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.orderId,
    this.tableNumber,
    this.dishName,
  });

  final String id;
  final CustomerNotificationKind kind;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final int? orderId;
  final int? tableNumber;
  final String? dishName;

  factory CustomerNotificationModel.fromOrderEvent(
    CustomerOrderWebSocketEvent event,
  ) {
    final createdAt = DateTime.now();
    final id = [
      createdAt.microsecondsSinceEpoch,
      event.orderId ?? 0,
      event.dishId ?? 0,
      event.orderStatus ?? event.itemStatus ?? 'UNKNOWN',
    ].join('-');

    if (event.type == CustomerOrderWebSocketEventType.orderItemStatusUpdated) {
      final dishName = event.dishName?.trim().isNotEmpty == true
          ? event.dishName!.trim()
          : 'Món ăn';
      return CustomerNotificationModel(
        id: id,
        kind: CustomerNotificationKind.orderItem,
        title: 'Cập nhật món ăn',
        message:
            '$dishName ${_itemStatusMessage(event.itemStatus)}'
            '${_orderSuffix(event.orderId)}.',
        createdAt: createdAt,
        isRead: false,
        orderId: event.orderId,
        tableNumber: event.tableNumber,
        dishName: dishName,
      );
    }

    if (event.type == CustomerOrderWebSocketEventType.paymentStatusUpdated ||
        event.type == CustomerOrderWebSocketEventType.paymentStatusReset) {
      return CustomerNotificationModel(
        id: id,
        kind: CustomerNotificationKind.payment,
        title: 'Cập nhật thanh toán',
        message:
            'Đơn hàng${_orderSuffix(event.orderId)} '
            '${_paymentStatusMessage(event.paymentStatus)}.',
        createdAt: createdAt,
        isRead: false,
        orderId: event.orderId,
        tableNumber: event.tableNumber,
      );
    }

    return CustomerNotificationModel(
      id: id,
      kind: CustomerNotificationKind.order,
      title: event.type == CustomerOrderWebSocketEventType.newOrder
          ? 'Đơn hàng đã được ghi nhận'
          : 'Cập nhật đơn hàng',
      message:
          'Đơn hàng${_orderSuffix(event.orderId)} '
          '${_orderStatusMessage(event.orderStatus)}.',
      createdAt: createdAt,
      isRead: false,
      orderId: event.orderId,
      tableNumber: event.tableNumber,
    );
  }

  CustomerNotificationModel copyWith({bool? isRead}) {
    return CustomerNotificationModel(
      id: id,
      kind: kind,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      orderId: orderId,
      tableNumber: tableNumber,
      dishName: dishName,
    );
  }

  String get timeLabel {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    }
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')} '
        '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';
  }

  static String _orderSuffix(int? orderId) {
    return orderId == null ? '' : ' #$orderId';
  }

  static String _orderStatusMessage(String? status) {
    return switch (status?.toUpperCase()) {
      'PENDING' => 'đang chờ xác nhận',
      'PROCESSING' => 'đang được xử lý',
      'COMPLETED' => 'đã hoàn tất',
      'CANCELLED' => 'đã bị hủy',
      'SCHEDULED' => 'đã được lên lịch',
      _ => 'đã được cập nhật trạng thái',
    };
  }

  static String _itemStatusMessage(String? status) {
    return switch (status?.toUpperCase()) {
      'PENDING' => 'đang chờ xử lý',
      'PROCESSING' => 'đang được chế biến',
      'COMPLETED' => 'đã hoàn thành',
      'CANCELLED' => 'đã bị hủy',
      _ => 'đã được cập nhật trạng thái',
    };
  }

  static String _paymentStatusMessage(String? status) {
    return switch (status?.toUpperCase()) {
      'PAID' => 'đã được thanh toán',
      'UNPAID' => 'đã được đặt lại về chưa thanh toán',
      'PENDING' => 'đang chờ xác nhận thanh toán',
      'CANCELLED' => 'đã hủy thanh toán',
      _ => 'đã được cập nhật thanh toán',
    };
  }
}
