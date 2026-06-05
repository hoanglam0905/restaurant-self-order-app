import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../models/staff_table_model.dart';
import '../models/table_notification_model.dart';

class TableService {
  const TableService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<StaffTableModel>> getTables() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/staff/tables');

      final data = response.data ?? <dynamic>[];

      return data
          .whereType<Map<String, dynamic>>()
          .map(StaffTableModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Lỗi tải danh sách bàn: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định khi tải danh sách bàn: $e');
    }
  }

  Future<StaffTableModel> getTableById(int tableId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/staff/tables/$tableId',
      );

      return StaffTableModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw Exception(
        'Lỗi tải chi tiết bàn: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định khi tải chi tiết bàn: $e');
    }
  }

  Future<List<TableNotificationModel>> getCurrentShiftNotifications() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        '/notifications/shift/current',
      );

      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu thông báo hiện tại không hợp lệ.');
      }

      return data
          .whereType<Map>()
          .map(
            (item) => TableNotificationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Lỗi tải thông báo hiện tại: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định khi tải thông báo hiện tại: $e');
    }
  }

  Future<List<TableNotificationModel>> getNotificationsByTable(
    int tableId,
  ) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        '/notifications/table/$tableId',
      );

      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu thông báo theo bàn không hợp lệ.');
      }

      return data
          .whereType<Map>()
          .map(
            (item) => TableNotificationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Lỗi tải thông báo theo bàn: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định khi tải thông báo theo bàn: $e');
    }
  }

  Future<Set<int>> getUnreadNotificationTableIds() async {
    final notifications = await getCurrentShiftNotifications();

    return notifications
        .where((notification) => !notification.isRead)
        .map((notification) => notification.tableNumber)
        .whereType<int>()
        .toSet();
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _apiClient.dio.put<dynamic>(
        '/notifications/$notificationId/read',
      );
    } on DioException catch (e) {
      throw Exception(
        'Lỗi đánh dấu thông báo đã đọc: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định khi đánh dấu thông báo đã đọc: $e');
    }
  }

  Future<void> markNotificationsAsRead(List<int> notificationIds) async {
    for (final notificationId in notificationIds) {
      await markNotificationAsRead(notificationId);
    }
  }

  Future<void> updateTableStatus({
    required int tableId,
    required String status,
  }) async {
    try {
      await _apiClient.dio.put(
        '/staff/tables/$tableId',
        data: {
          'status': status,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        'Lỗi cập nhật trạng thái bàn: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định khi cập nhật trạng thái bàn: $e');
    }
  }

  Future<void> swapTables({
    required int tableNumberA,
    required int tableNumberB,
  }) async {
    try {
      await _apiClient.dio.post(
        '/staff/tables/swap',
        queryParameters: {
          'tableNumberA': tableNumberA,
          'tableNumberB': tableNumberB,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        'Lỗi đổi bàn: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định khi đổi bàn: $e');
    }
  }
}