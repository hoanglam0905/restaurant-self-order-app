import 'package:dio/dio.dart';

import '../../../../../core/config/api_config.dart';
import '../../../../../core/network/api_client.dart';

class CallStaffOrderLookupService {
  const CallStaffOrderLookupService(this._apiClient);

  final ApiClient _apiClient;

  Future<CallStaffOrderLookupResult> findLatestUnpaidOrderForTable(
    int tableNumber,
  ) async {
    try {
      final orders = await _fetchOrders();
      final matchingOrders = orders
          .where(
            (order) =>
                order.tableNumber == tableNumber &&
                order.paymentStatus.toUpperCase() == 'UNPAID',
          )
          .toList();

      if (matchingOrders.isEmpty) {
        throw const CallStaffOrderLookupException(
          'Không tìm thấy đơn chưa thanh toán của bàn đã quét.',
        );
      }

      matchingOrders.sort((left, right) {
        final leftDate = left.orderDate ?? left.reservationTime ?? DateTime(0);
        final rightDate =
            right.orderDate ?? right.reservationTime ?? DateTime(0);
        return rightDate.compareTo(leftDate);
      });

      final order = matchingOrders.first;
      if (order.customerName == null || order.customerName!.trim().isEmpty) {
        throw const CallStaffOrderLookupException(
          'Đơn chưa thanh toán chưa có thông tin khách hàng.',
        );
      }

      final customerId = await _findCustomerIdByName(order.customerName!);
      return CallStaffOrderLookupResult(
        orderId: order.orderId,
        tableNumber: order.tableNumber,
        customerId: customerId,
      );
    } on CallStaffOrderLookupException {
      rethrow;
    } on DioException catch (error) {
      throw CallStaffOrderLookupException(_messageFromDio(error));
    } catch (_) {
      throw const CallStaffOrderLookupException(
        'Không thể xác định khách của bàn đã quét.',
      );
    }
  }

  Future<List<_OrderLookupItem>> _fetchOrders() async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiConfig.graphqlUrl,
      data: const {
        'query': '''
          query CallStaffOrders {
            orders {
              orderId
              customerName
              tableNumber
              paymentStatus
              reservationTime
              orderDate
            }
          }
        ''',
      },
      options: Options(extra: const {'skipAuth': true}),
    );

    final data = response.data;
    final errors = data?['errors'];
    if (errors is List && errors.isNotEmpty) {
      throw const CallStaffOrderLookupException(
        'Không thể tải danh sách đơn hàng.',
      );
    }

    final orders = data?['data']?['orders'];
    if (orders is! List) {
      throw const CallStaffOrderLookupException(
        'Phản hồi danh sách đơn hàng không hợp lệ.',
      );
    }

    return orders
        .whereType<Map<String, dynamic>>()
        .map(_OrderLookupItem.fromJson)
        .toList();
  }

  Future<int> _findCustomerIdByName(String customerName) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/customers',
      options: Options(extra: const {'skipAuth': true}),
    );

    final customers = response.data;
    if (customers == null) {
      throw const CallStaffOrderLookupException(
        'Không thể tải thông tin khách hàng.',
      );
    }

    final normalizedName = customerName.trim();
    for (final customer in customers.whereType<Map<String, dynamic>>()) {
      if (customer['fullname']?.toString().trim() == normalizedName) {
        final customerId = (customer['customerId'] as num?)?.toInt();
        if (customerId != null && customerId > 0) {
          return customerId;
        }
      }
    }

    throw const CallStaffOrderLookupException(
      'Không tìm thấy khách hàng của đơn chưa thanh toán.',
    );
  }

  String _messageFromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      401 => 'Không có quyền tải thông tin đơn hàng.',
      403 => 'Không có quyền tải thông tin đơn hàng.',
      404 => 'Không tìm thấy thông tin đơn hàng của bàn.',
      500 => 'Máy chủ chưa thể tải thông tin đơn hàng.',
      _ => 'Không thể kết nối đến máy chủ nhà hàng.',
    };
  }
}

class CallStaffOrderLookupResult {
  const CallStaffOrderLookupResult({
    required this.orderId,
    required this.tableNumber,
    required this.customerId,
  });

  final int orderId;
  final int tableNumber;
  final int customerId;
}

class CallStaffOrderLookupException implements Exception {
  const CallStaffOrderLookupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _OrderLookupItem {
  const _OrderLookupItem({
    required this.orderId,
    required this.tableNumber,
    required this.paymentStatus,
    this.customerName,
    this.reservationTime,
    this.orderDate,
  });

  final int orderId;
  final int tableNumber;
  final String paymentStatus;
  final String? customerName;
  final DateTime? reservationTime;
  final DateTime? orderDate;

  factory _OrderLookupItem.fromJson(Map<String, dynamic> json) {
    return _OrderLookupItem(
      orderId: int.tryParse(json['orderId'].toString()) ?? 0,
      tableNumber: (json['tableNumber'] as num?)?.toInt() ?? 0,
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      customerName: json['customerName']?.toString(),
      reservationTime: DateTime.tryParse(
        json['reservationTime']?.toString() ?? '',
      ),
      orderDate: DateTime.tryParse(json['orderDate']?.toString() ?? ''),
    );
  }
}
