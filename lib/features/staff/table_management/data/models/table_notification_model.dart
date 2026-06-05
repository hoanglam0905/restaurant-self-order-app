class TableNotificationModel {
  const TableNotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.isRead,
    required this.type,
    required this.createAt,
    this.tableNumber,
    this.orderId,
  });

  final int id;
  final String title;
  final String content;
  final bool isRead;
  final String type;
  final DateTime createAt;
  final int? tableNumber;
  final int? orderId;

  String get timeLabel {
    final hour = createAt.hour.toString().padLeft(2, '0');
    final minute = createAt.minute.toString().padLeft(2, '0');
    final second = createAt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  factory TableNotificationModel.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? '').toString();

    return TableNotificationModel(
      id: _asInt(json['notificationId']) ?? 0,
      title: title,
      content: (json['content'] ?? '').toString(),
      isRead: _asBool(json['isRead']),
      type: (json['type'] ?? 'OTHER').toString(),
      createAt: _parseDateTime(json['createAt']),
      tableNumber: _asInt(json['tableNumber']) ?? _extractTableNumber(title),
      orderId: _asInt(json['orderId']),
    );
  }

  TableNotificationModel copyWith({
    int? id,
    String? title,
    String? content,
    bool? isRead,
    String? type,
    DateTime? createAt,
    int? tableNumber,
    int? orderId,
  }) {
    return TableNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      createAt: createAt ?? this.createAt,
      tableNumber: tableNumber ?? this.tableNumber,
      orderId: orderId ?? this.orderId,
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool _asBool(dynamic value) {
    if (value == true) return true;
    if (value == false) return false;
    if (value is num) return value == 1;
    final raw = value?.toString().toLowerCase().trim();
    return raw == 'true' || raw == '1';
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    final raw = value.toString().trim();
    if (raw.isEmpty) return DateTime.now();

    return DateTime.tryParse(raw.replaceFirst(' ', 'T')) ?? DateTime.now();
  }

  static int? _extractTableNumber(String title) {
    final match = RegExp(
      r'Table\s+(\d+)',
      caseSensitive: false,
    ).firstMatch(title);

    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }
}