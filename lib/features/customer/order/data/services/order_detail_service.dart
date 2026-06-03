import 'package:dio/dio.dart';

import '../../../../../core/config/api_config.dart';
import '../../../../../core/network/api_client.dart';
import '../models/order_detail_model.dart';
import '../models/payment_process_result_model.dart';
import '../models/vnpay_payment_model.dart';

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
        ApiConfig.graphqlUrl,
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
      throw OrderDetailException(_orderMessageFromDio(error));
    } catch (_) {
      throw const OrderDetailException('Không thể tải đơn hàng.');
    }
  }

  Future<PaymentProcessResultModel> processPayment({
    required OrderDetailModel order,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiClient.dio.post<dynamic>(
        '/payment/process',
        data: {
          'orderId': order.orderId,
          'paymentMethod': paymentMethod,
          'amount': order.totalAmount,
          'confirmPayment': true,
          'pointsToUse': 0,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PaymentProcessResultModel.fromJson(data);
      }
      throw const OrderDetailException('Không thể xử lý thanh toán.');
    } on OrderDetailException {
      rethrow;
    } on DioException catch (error) {
      throw OrderDetailException(_paymentMessageFromDio(error));
    } catch (_) {
      throw const OrderDetailException('Không thể xử lý thanh toán.');
    }
  }

  Future<VNPayPaymentModel> createVNPayPayment(OrderDetailModel order) async {
    try {
      final response = await _apiClient.dio.post<dynamic>(
        '/payment/vnpay',
        data: {
          'total': order.totalAmount.round(),
          'orderInfo': 'Payment for Order: ${order.orderId}',
          'returnUrl': '${ApiConfig.baseUrl}/payment/vnpay_payment',
          'orderId': order.orderId,
          'pointsToUse': 0,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payment = VNPayPaymentModel.fromJson(data);
        if (payment.paymentUrl.trim().isEmpty) {
          throw const OrderDetailException('Backend chưa trả link VNPay.');
        }
        return payment;
      }

      throw const OrderDetailException('Không thể tạo thanh toán VNPay.');
    } on OrderDetailException {
      rethrow;
    } on DioException catch (error) {
      throw OrderDetailException(_paymentMessageFromDio(error));
    } catch (_) {
      throw const OrderDetailException('Không thể tạo thanh toán VNPay.');
    }
  }

  Future<OrderDetailModel> cancelPendingOrderItem({
    required int orderId,
    required int dishId,
  }) async {
    try {
      final response = await _apiClient.dio.delete<Map<String, dynamic>>(
        '/orders/$orderId/items/$dishId',
      );
      return OrderDetailModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw OrderDetailException(_cancelItemMessageFromDio(error));
    } catch (_) {
      throw const OrderDetailException('Không thể hủy món đã chọn.');
    }
  }

  String _orderMessageFromDio(DioException error) {
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

  String _paymentMessageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Thông tin thanh toán chưa hợp lệ.',
      401 => 'Vui lòng đăng nhập lại trước khi thanh toán.',
      403 => 'Bạn không có quyền thanh toán đơn hàng này.',
      404 => 'Không tìm thấy đơn hàng cần thanh toán.',
      409 => 'Đơn hàng này đã được thanh toán.',
      500 => 'Máy chủ chưa thể xử lý thanh toán.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }

  String _cancelItemMessageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return message;
      }
    }
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Chỉ có thể hủy món đang chờ xử lý.',
      401 => 'Vui lòng đăng nhập lại trước khi hủy món.',
      403 => 'Bạn không có quyền hủy món này.',
      404 => 'Không tìm thấy món trong đơn hàng.',
      500 => 'Máy chủ chưa thể hủy món.',
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
