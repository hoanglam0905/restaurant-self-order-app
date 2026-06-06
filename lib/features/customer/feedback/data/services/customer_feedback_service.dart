import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../models/create_feedback_request_model.dart';
import '../models/customer_feedback_model.dart';

class CustomerFeedbackService {
  const CustomerFeedbackService(this._apiClient);

  final ApiClient _apiClient;

  Future<CustomerFeedbackModel> createFeedback(
    CreateFeedbackRequestModel request,
  ) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/feedback',
        data: request.toJson(),
      );
      return CustomerFeedbackModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw CustomerFeedbackException(_messageFromDio(error));
    } catch (_) {
      throw const CustomerFeedbackException('Không thể gửi đánh giá.');
    }
  }

  Future<List<CustomerFeedbackModel>> getFeedbacks() async {
    try {
      final response = await _apiClient.dio.get<dynamic>('/feedback');
      final data = response.data;
      if (data is! List) {
        return const [];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(CustomerFeedbackModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw CustomerFeedbackException(_messageFromDio(error));
    } catch (_) {
      throw const CustomerFeedbackException('KhÃ´ng thá»ƒ táº£i Ä‘Ã¡nh giÃ¡.');
    }
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString() ?? data['error']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return message;
      }
    }

    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thông tin đánh giá chưa hợp lệ.',
      401 => 'Vui lòng đăng nhập lại trước khi đánh giá.',
      403 => 'Bạn không có quyền gửi đánh giá cho đơn này.',
      404 => 'Không tìm thấy đơn hàng cần đánh giá.',
      500 => 'Máy chủ chưa thể lưu đánh giá.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }
}

class CustomerFeedbackException implements Exception {
  const CustomerFeedbackException(this.message);

  final String message;

  @override
  String toString() => message;
}
