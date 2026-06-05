import 'table_status.dart';

class StaffTableModel {
  const StaffTableModel({
    required this.id,
    required this.capacity,
    required this.status,
    this.activeTimeText,
    this.orderProgressText,
    this.hasAlert = false,
  });

  final int id;
  final int capacity;
  final TableStatus status;
  final String? activeTimeText;
  final String? orderProgressText;
  final bool hasAlert;

  String get tableNumber => 'T-${id.toString().padLeft(2, '0')}';

  factory StaffTableModel.fromJson(Map<String, dynamic> json) {
    final tableId =
        (json['table_id'] as num?)?.toInt() ??
        (json['id'] as num?)?.toInt() ??
        0;

    final statusVal = TableStatus.fromJson(json['status'] as String?);

    String? activeTime;
    String? progress;

    if (statusVal == TableStatus.occupied) {
      progress = '8/15 Món';
      activeTime = switch (tableId) {
        1 => '45m active',
        3 => '1h 10m active',
        4 => '5m active',
        5 => '52m active',
        7 => '18m active',
        8 => '48m active',
        _ => '30m active',
      };
    }

    return StaffTableModel(
      id: tableId,
      capacity: (json['capacity'] as num?)?.toInt() ?? 4,
      status: statusVal,
      activeTimeText: activeTime,
      orderProgressText: progress,
      hasAlert: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table_id': id,
      'capacity': capacity,
      'status': status.toJson(),
    };
  }

  StaffTableModel copyWith({
    int? id,
    int? capacity,
    TableStatus? status,
    String? activeTimeText,
    String? orderProgressText,
    bool? hasAlert,
  }) {
    return StaffTableModel(
      id: id ?? this.id,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      activeTimeText: activeTimeText ?? this.activeTimeText,
      orderProgressText: orderProgressText ?? this.orderProgressText,
      hasAlert: hasAlert ?? this.hasAlert,
    );
  }
}