import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../models/customer_staff_request_notification_model.dart';

class CustomerStaffRequestNotificationService {
  const CustomerStaffRequestNotificationService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CustomerStaffRequestNotificationModel>> getTableNotifications(
    int tableNumber,
  ) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        '/notifications/table/$tableNumber',
      );
      final data = response.data;
      if (data is! List) {
        return const [];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(CustomerStaffRequestNotificationModel.fromJson)
          .toList();
    } on DioException {
      return const [];
    } catch (_) {
      return const [];
    }
  }
}
