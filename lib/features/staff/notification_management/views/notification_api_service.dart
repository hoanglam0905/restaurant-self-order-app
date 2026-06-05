import 'package:self_ordering_restaurant/core/network/api_client.dart';

import 'notification_api_model.dart';

class NotificationApiService {
  NotificationApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<NotificationApiModel>> getCurrentShiftNotifications() async {
    final response = await _apiClient.dio.get<dynamic>(
      '/notifications/shift/current',
    );

    final data = response.data;

    if (data is! List) {
      throw Exception('Dữ liệu thông báo không hợp lệ.');
    }

    return data
        .map(
          (item) =>
              NotificationApiModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> markAsRead(int notificationId) async {
    await _apiClient.dio.put<dynamic>(
      '/notifications/$notificationId/read',
    );
  }

  Future<void> deleteNotification(int notificationId) async {
    await _apiClient.dio.delete<dynamic>(
      '/notifications/$notificationId',
    );
  }
}