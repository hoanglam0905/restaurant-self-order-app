import 'package:get/get.dart';

import '../../../../core/storage/auth_session_storage.dart';
import '../data/models/create_feedback_request_model.dart';
import '../data/models/customer_feedback_model.dart';
import '../data/services/customer_feedback_service.dart';

class CustomerFeedbackController extends GetxController {
  CustomerFeedbackController({
    required CustomerFeedbackService feedbackService,
    AuthSessionStorage? authSessionStorage,
  }) : _feedbackService = feedbackService,
       _authSessionStorage = authSessionStorage ?? AuthSessionStorage();

  final CustomerFeedbackService _feedbackService;
  final AuthSessionStorage _authSessionStorage;

  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<CustomerFeedbackModel> submittedFeedback =
      Rxn<CustomerFeedbackModel>();

  Future<bool> submitFeedback({
    required int orderId,
    required int rating,
    required String comment,
    required List<String> selectedTags,
  }) async {
    if (rating < 1 || rating > 5) {
      errorMessage.value = 'Vui lòng chọn số sao đánh giá.';
      return false;
    }

    final session = await _authSessionStorage.readCustomerSession();
    if (session == null) {
      errorMessage.value = 'Vui lòng đăng nhập trước khi đánh giá.';
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      submittedFeedback.value = await _feedbackService.createFeedback(
        CreateFeedbackRequestModel(
          customerId: session.customerId,
          orderId: orderId,
          rating: rating,
          feedback: comment.trim().isEmpty
              ? 'Khách hàng không để lại nhận xét.'
              : comment.trim(),
          selectedTags: selectedTags,
        ),
      );
      return true;
    } on CustomerFeedbackException catch (error) {
      errorMessage.value = error.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Không thể gửi đánh giá.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
