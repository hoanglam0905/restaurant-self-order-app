import 'package:dio/dio.dart';

import '../../../../../core/config/api_config.dart';
import '../../../../../core/network/api_client.dart';

class OrderGraphqlService {
  OrderGraphqlService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<int> createOrder({
    required int tableId,
    required String customerName,
    required List<CreateOrderItemInput> items,
    String? notes,
  }) async {
    if (items.isEmpty) {
      throw Exception('Đơn hàng chưa có món nào.');
    }

    const mutation = r'''
mutation CreateOrder($input: OrderInput!) {
  createOrder(input: $input)
}
''';

    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.graphqlUrl,
        data: {
          'query': mutation,
          'variables': {
            'input': {
              'customerName': customerName,
              'tableId': tableId.toString(),
              'notes': notes ?? '',
              'items': items.map((item) => item.toJson()).toList(),
            },
          },
        },
      );

      final body = response.data ?? <String, dynamic>{};

      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw Exception(errors.map((error) => error.toString()).join('\n'));
      }

      final data = body['data'];
      if (data is! Map || data['createOrder'] == null) {
        throw Exception('Không nhận được orderId từ server.');
      }

      final orderId = data['createOrder'];

      if (orderId is int) return orderId;
      if (orderId is num) return orderId.toInt();

      return int.parse(orderId.toString());
    } on DioException catch (e) {
      throw Exception(
        'Tạo đơn hàng thất bại: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Tạo đơn hàng thất bại: $e');
    }
  }
}

class CreateOrderItemInput {
  const CreateOrderItemInput({
    required this.dishId,
    required this.quantity,
    this.notes,
  });

  final int dishId;
  final int quantity;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'dishId': dishId.toString(),
      'quantity': quantity,
      'notes': notes ?? '',
    };
  }
}