import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../models/order_detail_model.dart';

class OrderHistoryService {
  const OrderHistoryService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<OrderDetailModel>> getOrderHistory() async {
    try {
      final response = await _apiClient.dio.get<dynamic>('/customers/history');
      final data = response.data;
      if (data is! List<dynamic>) {
        throw const OrderHistoryException('Không thể tải lịch sử đơn hàng.');
      }

      final orders = data
          .whereType<Map<String, dynamic>>()
          .map(OrderDetailModel.fromJson)
          .toList();
      return Future.wait(orders.map(_attachPaymentDetails));
    } on OrderHistoryException {
      rethrow;
    } on DioException catch (error) {
      throw OrderHistoryException(_messageFromDio(error));
    } catch (_) {
      throw const OrderHistoryException('Không thể tải lịch sử đơn hàng.');
    }
  }

  Future<OrderDetailModel> _attachPaymentDetails(OrderDetailModel order) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/payment/payment/status/${order.orderId}',
      );
      final data = response.data ?? <String, dynamic>{};
      return order.copyWith(
        discount: (data['discount'] as num?)?.toDouble() ?? order.discount,
        totalAmount:
            (data['totalAmount'] as num?)?.toDouble() ?? order.totalAmount,
        paymentStatus: data['paymentStatus']?.toString() ?? order.paymentStatus,
      );
    } catch (_) {
      return order;
    }
  }

  String _messageFromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Không thể tải lịch sử đơn hàng.',
      401 => 'Vui lòng đăng nhập để xem lịch sử đơn hàng.',
      403 => 'Bạn không có quyền xem lịch sử đơn hàng.',
      404 => 'Không tìm thấy lịch sử đơn hàng.',
      500 => 'Máy chủ chưa thể tải lịch sử đơn hàng.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }
}

class OrderHistoryException implements Exception {
  const OrderHistoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
