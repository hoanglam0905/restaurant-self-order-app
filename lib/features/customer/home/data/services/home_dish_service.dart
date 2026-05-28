import 'package:dio/dio.dart';

import '../../../../../../core/network/api_client.dart';
import '../models/dish_model.dart';

class HomeDishService {
  const HomeDishService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<DishModel>> getDishes() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/dishes');
      final data = response.data ?? <dynamic>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(DishModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw HomeDishException(_messageFromDio(error));
    } catch (_) {
      throw const HomeDishException('Could not load dishes.');
    }
  }

  String _messageFromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Dish request is invalid.',
      401 => 'Please sign in again.',
      403 => 'You do not have access to this menu.',
      404 => 'Menu was not found.',
      500 => 'Server could not load the menu.',
      _ => 'Could not connect to the restaurant server.',
    };
  }
}

class HomeDishException implements Exception {
  const HomeDishException(this.message);

  final String message;

  @override
  String toString() => message;
}
