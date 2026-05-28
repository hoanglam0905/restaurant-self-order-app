import 'package:dio/dio.dart';

import '../../../../../../core/network/api_client.dart';
import '../models/forgot_password_request_model.dart';
import '../models/reset_password_request_model.dart';

class PasswordResetService {
  const PasswordResetService({required ApiClient apiClient})
    : _apiClient = apiClient;

  static const Duration _mailRequestTimeout = Duration(seconds: 30);

  final ApiClient _apiClient;

  Future<void> requestOtp(ForgotPasswordRequestModel request) async {
    try {
      await _postVoid('/auth/forgot-password', request.toJson());
    } on DioException catch (error) {
      throw PasswordResetException(_messageFromDio(error));
    } catch (_) {
      throw const PasswordResetException('Không thể gửi mã xác nhận.');
    }
  }

  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    try {
      await _postVoid('/auth/reset-password', request.toJson());
    } on DioException catch (error) {
      throw PasswordResetException(_messageFromDio(error));
    } catch (_) {
      throw const PasswordResetException('Không thể đặt lại mật khẩu.');
    }
  }

  Future<void> _postVoid(String path, Map<String, dynamic> data) async {
    await _apiClient.dio.post<dynamic>(
      path,
      data: data,
      options: Options(
        receiveTimeout: _mailRequestTimeout,
        responseType: ResponseType.plain,
        sendTimeout: _mailRequestTimeout,
      ),
    );
  }

  String _messageFromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thông tin không hợp lệ.',
      401 => 'Mã xác nhận không hợp lệ.',
      403 => 'Bạn không có quyền thực hiện thao tác này.',
      404 => 'Không tìm thấy tài khoản.',
      500 => 'Máy chủ chưa thể xử lý yêu cầu.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }
}

class PasswordResetException implements Exception {
  const PasswordResetException(this.message);

  final String message;

  @override
  String toString() => message;
}
