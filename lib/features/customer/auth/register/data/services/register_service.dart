import 'package:dio/dio.dart';

import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/storage/token_storage.dart';
import '../../../data/models/auth_response_model.dart';
import '../models/register_request_model.dart';
import '../models/verify_register_otp_request_model.dart';

class RegisterService {
  RegisterService({required ApiClient apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient,
      _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/customer/register',
        data: request.toJson(),
      );

      return AuthResponseModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw RegisterException(_messageFromDio(error));
    } on RegisterException {
      rethrow;
    } catch (_) {
      throw const RegisterException('Không thể đăng ký.');
    }
  }

  Future<AuthResponseModel> verifyRegisterOtp(
    VerifyRegisterOtpRequestModel request,
  ) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/customer/verify-register-otp',
        data: request.toJson(),
      );
      final auth = AuthResponseModel.fromJson(response.data ?? {});

      if (auth.accessToken.isEmpty || auth.refreshToken.isEmpty) {
        throw const RegisterException(
          'Máy chủ chưa trả về token hợp lệ sau khi xác thực OTP.',
        );
      }

      await _tokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );

      return auth;
    } on DioException catch (error) {
      throw RegisterException(_messageFromDio(error));
    } on RegisterException {
      rethrow;
    } catch (_) {
      throw const RegisterException('Không thể xác thực OTP.');
    }
  }

  String _messageFromDio(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Máy chủ đang phản hồi chậm. Vui lòng thử lại sau ít phút.',
      DioExceptionType.connectionError =>
        'Không thể kết nối đến máy chủ nhà hàng. Vui lòng kiểm tra mạng.',
      _ => _messageFromStatusCode(error),
    };
  }

  String _messageFromStatusCode(DioException error) {
    final serverMessage = _serverMessage(error.response?.data);
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thông tin đăng ký hoặc OTP không hợp lệ.',
      401 => 'Phiên đăng ký không hợp lệ.',
      403 => 'Bạn không có quyền tạo tài khoản này.',
      404 => 'Không tìm thấy dịch vụ đăng ký.',
      409 => 'Email hoặc tên đăng nhập đã tồn tại.',
      500 => 'Máy chủ chưa thể xử lý đăng ký.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }

  String? _serverMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    if (data is Map) {
      return data['message']?.toString();
    }
    return null;
  }
}

class RegisterException implements Exception {
  const RegisterException(this.message);

  final String message;

  @override
  String toString() => message;
}
