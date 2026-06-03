import 'package:dio/dio.dart';

import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/storage/auth_session_storage.dart';
import '../../../../../../core/storage/token_storage.dart';
import '../../../data/models/auth_response_model.dart';
import '../models/google_login_request_model.dart';
import '../models/login_request_model.dart';

class LoginService {
  LoginService({
    required ApiClient apiClient,
    TokenStorage? tokenStorage,
    AuthSessionStorage? authSessionStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage ?? TokenStorage(),
       _authSessionStorage = authSessionStorage ?? AuthSessionStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  final AuthSessionStorage _authSessionStorage;

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
        options: Options(extra: const {'skipAuth': true}),
      );
      final auth = AuthResponseModel.fromJson(response.data ?? {});

      await _saveTokens(auth);

      return auth;
    } on DioException catch (error) {
      throw LoginException(_messageFromDio(error));
    } on LoginException {
      rethrow;
    } catch (_) {
      throw const LoginException('Không thể đăng nhập.');
    }
  }

  Future<AuthResponseModel> staffGoogleLogin(
    GoogleLoginRequestModel request,
  ) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/staff/google-login',
        data: request.toJson(),
        options: Options(extra: const {'skipAuth': true}),
      );
      final auth = AuthResponseModel.fromJson(response.data ?? {});

      await _saveTokens(auth);

      return auth;
    } on DioException catch (error) {
      throw LoginException(_messageFromDio(error));
    } on LoginException {
      rethrow;
    } catch (_) {
      throw const LoginException('Không thể đăng nhập bằng Google.');
    }
  }

  Future<void> _saveTokens(AuthResponseModel auth) async {
    if (auth.accessToken.isEmpty || auth.refreshToken.isEmpty) {
      throw const LoginException('Máy chủ chưa trả về token hợp lệ.');
    }

    await _tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );

    await _authSessionStorage.saveAuthProfile(
      userType: auth.userType,
      customerId: auth.customerId,
      customerName: auth.fullName,
      staffId: auth.staffId,
      staffName: auth.fullName,
      username: auth.username,
      email: auth.email,
    );
  }

  String _messageFromDio(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Máy chủ đang phản hồi chậm. Vui lòng thử lại sau ít phút.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến máy chủ nhà hàng. Vui lòng kiểm tra mạng.';
    }

    final serverMessage = _serverMessage(error.response?.data);
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thông tin đăng nhập không hợp lệ.',
      401 => 'Email hoặc mật khẩu không đúng.',
      403 => 'Tài khoản này không có quyền truy cập.',
      404 => 'Không tìm thấy tài khoản.',
      500 => 'Máy chủ chưa thể xử lý đăng nhập.',
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
    if (data is String) {
      return data;
    }
    return null;
  }
}

class LoginException implements Exception {
  const LoginException(this.message);

  final String message;

  @override
  String toString() => message;
}