class CreateFeedbackRequestModel {
  const CreateFeedbackRequestModel({
    required this.customerId,
    required this.orderId,
    required this.rating,
    required this.feedback,
    required this.selectedTags,
  });

  final int customerId;
  final int orderId;
  final int rating;
  final String feedback;
  final List<String> selectedTags;

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'orderId': orderId,
      'rating': rating,
      'feedback': feedback,
      'selectedTags': selectedTags,
    };
  }
}
