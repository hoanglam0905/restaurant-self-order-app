import 'package:dio/dio.dart';

import '../../../../../core/config/api_config.dart';
import '../../../../../core/network/api_client.dart';
import '../models/order_detail_model.dart';

class OrderDetailService {
  const OrderDetailService(this._apiClient);

  static const String _orderQuery = r'''
query OrderDetail($orderId: ID!) {
  order(orderId: $orderId) {
    orderId
    customerName
    tableNumber
    status
    totalAmount
    paymentStatus
    reservationTime
    items {
      dishId
      dishName
      price
      quantity
      notes
      status
    }
  }
}
''';

  final ApiClient _apiClient;

  Future<OrderDetailModel> getOrderDetail(int orderId) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '${ApiConfig.backendOrigin}/graphql',
        data: {
          'query': _orderQuery,
          'variables': {'orderId': orderId.toString()},
        },
      );

      final body = response.data ?? <String, dynamic>{};
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw const OrderDetailException('Không thể tải đơn hàng.');
      }

      final data = body['data'];
      if (data is! Map<String, dynamic> ||
          data['order'] is! Map<String, dynamic>) {
        throw const OrderDetailException('Không tìm thấy đơn hàng.');
      }

      return OrderDetailModel.fromJson(data['order'] as Map<String, dynamic>);
    } on OrderDetailException {
      rethrow;
    } on DioException catch (error) {
      throw OrderDetailException(_messageFromDio(error));
    } catch (_) {
      throw const OrderDetailException('Không thể tải đơn hàng.');
    }
  }

  String _messageFromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thông tin đơn hàng chưa hợp lệ.',
      401 => 'Vui lòng đăng nhập lại.',
      403 => 'Bạn không có quyền xem đơn hàng này.',
      404 => 'Không tìm thấy đơn hàng.',
      500 => 'Máy chủ chưa thể tải đơn hàng.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }
}

class OrderDetailException implements Exception {
  const OrderDetailException(this.message);

  final String message;

  @override
  String toString() => message;
}
