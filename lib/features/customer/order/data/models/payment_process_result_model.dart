class PaymentProcessResultModel {
  const PaymentProcessResultModel({
    required this.success,
    required this.message,
    this.transactionId,
    this.paymentStatus,
  });

  final bool success;
  final String message;
  final String? transactionId;
  final String? paymentStatus;

  factory PaymentProcessResultModel.fromJson(Map<String, dynamic> json) {
    return PaymentProcessResultModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? 'Không thể xử lý thanh toán.',
      transactionId: json['transactionId']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
    );
  }
}
