import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../../core/config/api_config.dart';
import '../../../../../core/storage/token_storage.dart';
import '../models/staff_kitchen_order_model.dart';

class KitchenService {
  KitchenService({
    this.graphqlUrl = ApiConfig.graphqlUrl,
    TokenStorage? tokenStorage,
  }) : _tokenStorage = tokenStorage ?? TokenStorage();

  final String graphqlUrl;
  final TokenStorage _tokenStorage;

  Future<Map<String, String>> _headers() async {
    final accessToken = await _tokenStorage.readAccessToken();

    return {
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  Future<List<StaffKitchenOrderModel>> getKitchenOrders() async {
    const query = '''
      query {
        orders {
          orderId
          customerName
          tableNumber
          status
          totalAmount
          paymentStatus
          items {
            dishId
            dishName
            quantity
            notes
            price
            status
          }
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(graphqlUrl),
      headers: await _headers(),
      body: jsonEncode({
        'query': query,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể tải đơn bếp: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (decoded['errors'] != null) {
      throw Exception('GraphQL lỗi: ${jsonEncode(decoded['errors'])}');
    }

    final ordersJson = decoded['data']?['orders'];

    if (ordersJson is! List) {
      throw Exception('Dữ liệu orders không đúng định dạng');
    }

    return ordersJson
        .whereType<Map<String, dynamic>>()
        .map(StaffKitchenOrderModel.fromJson)
        .toList();
  }

  Future<void> updateOrderItemStatus({
    required int orderId,
    required int dishId,
    required String status,
  }) async {
    const mutation = '''
      mutation UpdateOrderItemStatus(\$orderId: ID!, \$dishId: ID!, \$status: String!) {
        updateOrderItemStatus(orderId: \$orderId, dishId: \$dishId, status: \$status) {
          orderId
          status
          items {
            dishId
            status
          }
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(graphqlUrl),
      headers: await _headers(),
      body: jsonEncode({
        'query': mutation,
        'variables': {
          'orderId': orderId.toString(),
          'dishId': dishId.toString(),
          'status': status,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể cập nhật trạng thái món: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (decoded['errors'] != null) {
      throw Exception('GraphQL lỗi: ${jsonEncode(decoded['errors'])}');
    }
  }
}