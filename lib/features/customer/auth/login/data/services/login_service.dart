import 'package:dio/dio.dart';

import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/storage/token_storage.dart';
import '../../../data/models/auth_response_model.dart';
import '../models/google_login_request_model.dart';
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
      throw const LoginException('Khong the dang nhap.');
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
      throw const LoginException('Khong the dang nhap bang Google.');
    }
  }

  Future<void> _saveTokens(AuthResponseModel auth) async {
    if (auth.accessToken.isEmpty || auth.refreshToken.isEmpty) {
      throw const LoginException('May chu chua tra ve token hop le.');
    }

    await _tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
  }

  String _messageFromDio(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'May chu dang phan hoi cham. Vui long thu lai sau it phut.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Khong the ket noi den may chu nha hang. Vui long kiem tra mang.';
    }

    final serverMessage = _serverMessage(error.response?.data);
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thong tin dang nhap khong hop le.',
      401 => 'Email hoac mat khau khong dung.',
      403 => 'Tai khoan nay khong co quyen truy cap.',
      404 => 'Khong tim thay tai khoan.',
      500 => 'May chu chua the xu ly dang nhap.',
      _ => 'Khong the ket noi den may chu nha hang.',
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

class LoginException implements Exception {
  const LoginException(this.message);

  final String message;

  @override
  String toString() => message;
}
