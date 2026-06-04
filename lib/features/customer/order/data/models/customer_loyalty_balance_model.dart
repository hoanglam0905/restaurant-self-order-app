class CustomerLoyaltyBalanceModel {
  const CustomerLoyaltyBalanceModel({
    required this.customerId,
    required this.fullName,
    required this.points,
  });

  final int customerId;
  final String fullName;
  final int points;

  factory CustomerLoyaltyBalanceModel.fromJson(Map<String, dynamic> json) {
    return CustomerLoyaltyBalanceModel(
      customerId: (json['customerId'] as num?)?.toInt() ?? 0,
      fullName: json['fullname'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }
}
