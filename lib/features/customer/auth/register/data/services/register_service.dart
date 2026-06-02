import 'package:dio/dio.dart';

import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/storage/auth_session_storage.dart';
import '../../../../../../core/storage/token_storage.dart';
import '../../../data/models/auth_response_model.dart';
import '../models/register_request_model.dart';
import '../models/verify_register_otp_request_model.dart';

class RegisterService {
  RegisterService({
    required ApiClient apiClient,
    TokenStorage? tokenStorage,
    AuthSessionStorage? authSessionStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage ?? TokenStorage(),
       _authSessionStorage = authSessionStorage ?? AuthSessionStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  final AuthSessionStorage _authSessionStorage;

  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/customer/register',
        data: request.toJson(),
        options: Options(extra: const {'skipAuth': true}),
      );

      return AuthResponseModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw RegisterException(_messageFromDio(error));
    } on RegisterException {
      rethrow;
    } catch (_) {
      throw const RegisterException('Khong the dang ky.');
    }
  }

  Future<AuthResponseModel> verifyRegisterOtp(
    VerifyRegisterOtpRequestModel request,
  ) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/customer/verify-register-otp',
        data: request.toJson(),
        options: Options(extra: const {'skipAuth': true}),
      );
      final auth = AuthResponseModel.fromJson(response.data ?? {});

      if (auth.accessToken.isEmpty || auth.refreshToken.isEmpty) {
        throw const RegisterException(
          'May chu chua tra ve token hop le sau khi xac thuc OTP.',
        );
      }

      await _tokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      await _authSessionStorage.saveAuthProfile(
        userType: auth.userType,
        customerId: auth.customerId,
        customerName: auth.fullName,
      );

      return auth;
    } on DioException catch (error) {
      throw RegisterException(_messageFromDio(error));
    } on RegisterException {
      rethrow;
    } catch (_) {
      throw const RegisterException('Khong the xac thuc OTP.');
    }
  }

  Future<void> resendRegisterOtp(String email) async {
    try {
      await _apiClient.dio.post<void>(
        '/auth/customer/resend-register-otp',
        queryParameters: {'email': email},
        options: Options(extra: const {'skipAuth': true}),
      );
    } on DioException catch (error) {
      throw RegisterException(_messageFromDio(error));
    } catch (_) {
      throw const RegisterException('Khong the gui lai OTP.');
    }
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
      400 => 'Thong tin dang ky hoac OTP khong hop le.',
      401 => 'Phien dang ky khong hop le.',
      403 => 'Ban khong co quyen tao tai khoan nay.',
      404 => 'Khong tim thay dich vu dang ky.',
      409 => 'Email hoac ten dang nhap da ton tai.',
      500 => 'May chu chua the xu ly dang ky.',
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

class RegisterException implements Exception {
  const RegisterException(this.message);

  final String message;

  @override
  String toString() => message;
}
