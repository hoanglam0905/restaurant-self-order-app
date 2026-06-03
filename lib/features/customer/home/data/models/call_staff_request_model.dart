class CallStaffRequestModel {
  const CallStaffRequestModel({
    required this.tableNumber,
    required this.customerId,
    required this.additionalMessage,
    this.orderId,
  });

  final int tableNumber;
  final int customerId;
  final int? orderId;
  final String additionalMessage;

  Map<String, dynamic> toJson() {
    return {
      'tableNumber': tableNumber,
      'customerId': customerId,
      'orderId': orderId,
      'type': 'CALL_STAFF',
      'additionalMessage': additionalMessage,
    };
  }
}
