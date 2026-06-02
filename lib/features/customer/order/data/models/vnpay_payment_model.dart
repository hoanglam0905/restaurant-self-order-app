class VNPayPaymentModel {
  const VNPayPaymentModel({
    required this.paymentUrl,
    required this.message,
    this.transactionStatus,
    this.responseCode,
  });

  final String paymentUrl;
  final String message;
  final String? transactionStatus;
  final String? responseCode;

  factory VNPayPaymentModel.fromJson(Map<String, dynamic> json) {
    return VNPayPaymentModel(
      paymentUrl: json['paymentUrl']?.toString() ?? '',
      message: json['message']?.toString() ?? 'Đã tạo liên kết VNPay.',
      transactionStatus: json['transactionStatus']?.toString(),
      responseCode: json['responseCode']?.toString(),
    );
  }
}
