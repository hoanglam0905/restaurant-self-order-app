class CustomerSettingsProfile {
  const CustomerSettingsProfile({
    required this.customerId,
    required this.fullName,
    required this.points,
    this.joinDate,
  });

  final int customerId;
  final String fullName;
  final int points;
  final DateTime? joinDate;

  factory CustomerSettingsProfile.fromJson(Map<String, dynamic> json) {
    return CustomerSettingsProfile(
      customerId: (json['customerId'] as num?)?.toInt() ?? 0,
      fullName: json['fullname'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      joinDate: DateTime.tryParse(json['joinDate'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toUpdateJson({required String fullName}) {
    return {
      'fullname': fullName,
      'joinDate': joinDate?.toIso8601String(),
      'points': points,
    };
  }

  CustomerSettingsProfile copyWith({
    String? fullName,
    int? points,
    DateTime? joinDate,
  }) {
    return CustomerSettingsProfile(
      customerId: customerId,
      fullName: fullName ?? this.fullName,
      points: points ?? this.points,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}
