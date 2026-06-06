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

  final RxBool isLoadingExistingFeedback = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<CustomerFeedbackModel> existingFeedback =
      Rxn<CustomerFeedbackModel>();
  final Rxn<CustomerFeedbackModel> submittedFeedback =
      Rxn<CustomerFeedbackModel>();

  Future<void> loadExistingFeedback(int orderId) async {
    isLoadingExistingFeedback.value = true;
    errorMessage.value = '';

    try {
      final feedbacks = await _feedbackService.getFeedbacks();
      final matching = feedbacks
          .where((feedback) => feedback.orderId == orderId)
          .toList();
      matching.sort((left, right) => right.id.compareTo(left.id));
      existingFeedback.value = matching.isEmpty ? null : matching.first;
    } on CustomerFeedbackException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Khong the kiem tra danh gia da gui.';
    } finally {
      isLoadingExistingFeedback.value = false;
    }
  }

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

    if (existingFeedback.value != null) {
      errorMessage.value = 'Don hang nay da duoc danh gia.';
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
      existingFeedback.value = submittedFeedback.value;
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
