import 'package:dio/dio.dart';

import '../../../../../../core/network/api_client.dart';
import '../models/customer_settings_profile.dart';

class CustomerSettingsService {
  const CustomerSettingsService(this._apiClient);

  final ApiClient _apiClient;

  Future<CustomerSettingsProfile> getProfile(int customerId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/customers/$customerId',
      );
      return CustomerSettingsProfile.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw CustomerSettingsException(_messageFromDio(error));
    } catch (_) {
      throw const CustomerSettingsException(
        'Không thể tải thông tin tài khoản.',
      );
    }
  }

  Future<CustomerSettingsProfile> updateProfileName({
    required CustomerSettingsProfile profile,
    required String fullName,
  }) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/customers/${profile.customerId}',
        data: profile.toUpdateJson(fullName: fullName),
      );
      return CustomerSettingsProfile.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw CustomerSettingsException(_messageFromDio(error));
    } catch (_) {
      throw const CustomerSettingsException('Không thể cập nhật tài khoản.');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post<void>('/auth/logout');
    } on DioException catch (error) {
      throw CustomerSettingsException(_messageFromDio(error));
    } catch (_) {
      throw const CustomerSettingsException('Không thể đăng xuất.');
    }
  }

  String _messageFromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Máy chủ không chấp nhận yêu cầu cài đặt.',
      401 => 'Vui lòng đăng nhập lại để tiếp tục.',
      403 => 'Bạn không có quyền thực hiện thao tác này.',
      404 => 'Không tìm thấy thông tin tài khoản.',
      500 => 'Máy chủ chưa thể xử lý cài đặt.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }
}

class CustomerSettingsException implements Exception {
  const CustomerSettingsException(this.message);

  final String message;

  @override
  String toString() => message;
}
