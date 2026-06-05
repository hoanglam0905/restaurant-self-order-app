class CustomerFeedbackModel {
  const CustomerFeedbackModel({
    required this.id,
    required this.customerName,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.time,
    required this.date,
    required this.checked,
  });

  final int id;
  final String customerName;
  final int? orderId;
  final int rating;
  final String comment;
  final String time;
  final String date;
  final bool checked;

  factory CustomerFeedbackModel.fromJson(Map<String, dynamic> json) {
    return CustomerFeedbackModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      customerName: json['customerName']?.toString() ?? '',
      orderId: (json['orderId'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      checked: json['checked'] as bool? ?? false,
    );
  }
}
