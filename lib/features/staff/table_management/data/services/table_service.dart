import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../models/staff_table_model.dart';

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