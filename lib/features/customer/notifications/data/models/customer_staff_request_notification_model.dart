class CustomerStaffRequestNotificationModel {
  const CustomerStaffRequestNotificationModel({
    required this.notificationId,
    required this.title,
    required this.content,
    required this.isRead,
    required this.type,
    this.tableNumber,
    this.orderId,
  });

  final int notificationId;
  final String title;
  final String content;
  final bool isRead;
  final String type;
  final int? tableNumber;
  final int? orderId;

  bool get isHandledStaffRequest {
    final normalizedType = type.toUpperCase();
    return isRead &&
        (normalizedType == 'CALL_STAFF' || normalizedType == 'PAYMENT_REQUEST');
  }

  bool get isPaymentRequest => type.toUpperCase() == 'PAYMENT_REQUEST';

  factory CustomerStaffRequestNotificationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomerStaffRequestNotificationModel(
      notificationId: (json['notificationId'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? false,
      type: json['type']?.toString() ?? '',
      tableNumber: (json['tableNumber'] as num?)?.toInt(),
      orderId: (json['orderId'] as num?)?.toInt(),
    );
  }
}
