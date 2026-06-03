import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../models/call_staff_request_model.dart';

class HomeNotificationService {
  const HomeNotificationService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> callStaff(CallStaffRequestModel request) async {
    try {
      await _apiClient.dio.post<Map<String, dynamic>>(
        '/notifications',
        data: request.toJson(),
      );
    } on DioException catch (error) {
      throw HomeNotificationException(_messageFromDio(error));
    } catch (_) {
      throw const HomeNotificationException(
        'Không thể gửi yêu cầu gọi nhân viên.',
      );
    }
  }

  String _messageFromDio(DioException error) {
    final serverMessage = _serverMessage(error.response?.data);
    if (serverMessage != null && serverMessage.isNotEmpty) {
      if (serverMessage.contains('No staff are currently on shift')) {
        return 'Hiện chưa có nhân viên nào trong ca trực.';
      }
      if (serverMessage.contains('Customer not found')) {
        return 'Không tìm thấy tài khoản khách hàng.';
      }
      if (serverMessage.contains('Table not found')) {
        return 'Không tìm thấy bàn đã quét.';
      }
      return serverMessage;
    }

    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thông tin gọi nhân viên chưa hợp lệ.',
      401 => 'Vui lòng đăng nhập để gọi nhân viên.',
      403 => 'Bạn không có quyền gửi yêu cầu này.',
      404 => 'Không tìm thấy bàn hoặc khách hàng.',
      500 => 'Máy chủ chưa thể gửi yêu cầu gọi nhân viên.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }

  String? _serverMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      return data['error'] as String? ?? data['message'] as String?;
    }
    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString();
    }
    return data?.toString();
  }
}

class HomeNotificationException implements Exception {
  const HomeNotificationException(this.message);

  final String message;

  @override
  String toString() => message;
}
