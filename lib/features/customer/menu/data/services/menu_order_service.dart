import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../models/order_request_model.dart';

class MenuOrderService {
  const MenuOrderService(this._apiClient);

  final ApiClient _apiClient;

  Future<int> createOrder(OrderRequestModel request) async {
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
      throw MenuOrderException(_messageFromDio(error));
    } catch (_) {
      throw const MenuOrderException('Không thể xác nhận đơn hàng.');
    }
  }

  String _messageFromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thông tin đơn hàng chưa hợp lệ.',
      401 => 'Vui lòng đăng nhập lại trước khi đặt món.',
      403 => 'Bạn chưa có quyền đặt món cho bàn này.',
      404 => 'Không tìm thấy bàn hoặc món ăn.',
      500 => 'Máy chủ chưa thể tạo đơn hàng.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }
}

class MenuOrderException implements Exception {
  const MenuOrderException(this.message);

  final String message;

  @override
  String toString() => message;
}
