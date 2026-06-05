class NotificationApiModel {
  const NotificationApiModel({
    required this.notificationId,
    required this.title,
    required this.content,
    required this.isRead,
    required this.type,
    required this.createAt,
    this.tableNumber,
    this.orderId,
  });

  final int notificationId;
  final String title;
  final String content;
  final bool isRead;
  final String type;
  final DateTime createAt;
  final int? tableNumber;
  final int? orderId;

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationApiModel(
      notificationId: _asInt(json['notificationId']) ?? 0,
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      isRead: json['isRead'] == true,
      type: (json['type'] ?? 'OTHER').toString(),
      createAt: _parseDateTime(json['createAt']),
      tableNumber: _asInt(json['tableNumber']),
      orderId: _asInt(json['orderId']),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    final raw = value.toString().trim();
    if (raw.isEmpty) return DateTime.now();

    return DateTime.tryParse(raw.replaceFirst(' ', 'T')) ?? DateTime.now();
  }
}