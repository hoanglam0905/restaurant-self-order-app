class LoyaltyPointsApplicationModel {
  const LoyaltyPointsApplicationModel({
    required this.success,
    required this.message,
    required this.discount,
    required this.payableAmount,
  });

  final bool success;
  final String message;
  final double discount;
  final double payableAmount;

  factory LoyaltyPointsApplicationModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyPointsApplicationModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      payableAmount: (json['payableAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}
