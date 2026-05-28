import 'package:dio/dio.dart';

import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/storage/token_storage.dart';
import '../../../data/models/auth_response_model.dart';
import '../models/login_request_model.dart';

class LoginService {
  LoginService({required ApiClient apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient,
      _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );
      final auth = AuthResponseModel.fromJson(response.data ?? {});

      if (auth.accessToken.isEmpty || auth.refreshToken.isEmpty) {
        throw const LoginException('Máy chủ chưa trả về token hợp lệ.');
      }

      await _tokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );

      return auth;
    } on DioException catch (error) {
      throw LoginException(_messageFromDio(error));
    } on LoginException {
      rethrow;
    } catch (_) {
      throw const LoginException('Không thể đăng nhập.');
    }
  }

  String _messageFromDio(DioException error) {
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
}

class LoginException implements Exception {
  const LoginException(this.message);

  final String message;

  @override
  String toString() => message;
}
