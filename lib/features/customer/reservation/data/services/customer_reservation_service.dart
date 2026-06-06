import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../../../order/data/models/order_detail_model.dart';
import '../models/create_reservation_request_model.dart';

class CustomerReservationService {
  const CustomerReservationService(this._apiClient);

  final ApiClient _apiClient;

  Future<int> createReservation(CreateReservationRequestModel request) async {
    try {
      final response = await _apiClient.dio.post<dynamic>(
        '/orders',
        data: request.toJson(),
      );
      final data = response.data;
      if (data is num) {
        return data.toInt();
      }
      return int.tryParse(data.toString()) ?? 0;
    } on DioException catch (error) {
      throw CustomerReservationException(_messageFromDio(error));
    } catch (_) {
      throw const CustomerReservationException(
        'Không thể gửi yêu cầu đặt bàn.',
      );
    }
  }

  Future<List<OrderDetailModel>> getReservationHistory() async {
    try {
      final response = await _apiClient.dio.get<dynamic>('/customers/history');
      final data = response.data;
      if (data is! List<dynamic>) {
        throw const CustomerReservationException(
          'Không thể tải lịch sử đặt bàn.',
        );
      }

      final reservations =
          data
              .whereType<Map<String, dynamic>>()
              .map(OrderDetailModel.fromJson)
              .where((order) => order.reservationTime != null)
              .toList()
            ..sort((a, b) {
              final left = a.reservationTime ?? DateTime(0);
              final right = b.reservationTime ?? DateTime(0);
              return right.compareTo(left);
            });

      return reservations;
    } on CustomerReservationException {
      rethrow;
    } on DioException catch (error) {
      throw CustomerReservationException(_historyMessageFromDio(error));
    } catch (_) {
      throw const CustomerReservationException(
        'Không thể tải lịch sử đặt bàn.',
      );
    }
  }

  String _messageFromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thông tin đặt bàn chưa hợp lệ.',
      401 => 'Vui lòng đăng nhập lại trước khi đặt bàn.',
      403 => 'Bạn chưa có quyền gửi yêu cầu đặt bàn.',
      404 => 'Không tìm thấy bàn đã chọn.',
      500 => 'Máy chủ chưa thể tạo yêu cầu đặt bàn.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }

  String _historyMessageFromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Không thể tải lịch sử đặt bàn.',
      401 => 'Vui lòng đăng nhập để xem lịch sử đặt bàn.',
      403 => 'Bạn chưa có quyền xem lịch sử đặt bàn.',
      404 => 'Không tìm thấy lịch sử đặt bàn.',
      500 => 'Máy chủ chưa thể tải lịch sử đặt bàn.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }
}

class CustomerReservationException implements Exception {
  const CustomerReservationException(this.message);

  final String message;

  @override
  String toString() => message;
}
