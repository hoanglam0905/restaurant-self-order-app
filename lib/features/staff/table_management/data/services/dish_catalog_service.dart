import '../../../../../core/config/api_config.dart';
import '../../../../../core/network/api_client.dart';
import '../models/order_dish_model.dart';

class DishCatalogService {
  DishCatalogService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<OrderDishModel>> getDishes() async {
    final response = await _apiClient.dio.get<dynamic>('/dishes');

    final data = response.data;

    if (data is! List) {
      throw Exception('Dữ liệu món ăn không đúng định dạng.');
    }

    return data
        .whereType<Map>()
        .map((item) {
          final json = Map<String, dynamic>.from(item);
          final normalizedImageUrl = _normalizeImageUrl(json['imageUrl']);

          return OrderDishModel.fromJson({
            ...json,
            'imageUrl': normalizedImageUrl,
          });
        })
        .where((dish) => dish.dishId > 0)
        .toList();
  }

  String? _normalizeImageUrl(dynamic value) {
    if (value == null) return null;

    final raw = value.toString().trim();

    if (raw.isEmpty) return null;

    final apiBaseUrl = ApiConfig.baseUrl;
    final appBaseUrl = apiBaseUrl.replaceFirst(RegExp(r'/api/?$'), '');

    if (raw.startsWith('http://localhost:8080/')) {
      return raw.replaceFirst('http://localhost:8080', appBaseUrl);
    }

    if (raw.startsWith('https://localhost:8080/')) {
      return raw.replaceFirst('https://localhost:8080', appBaseUrl);
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    if (raw.startsWith('/')) {
      return '$appBaseUrl$raw';
    }

    return '$appBaseUrl/uploads/dishes/$raw';
  }
}