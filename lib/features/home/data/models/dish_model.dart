import '../../../../../core/config/api_config.dart';
import 'dish_status.dart';

class DishModel {
  const DishModel({
    required this.dishId,
    required this.dishName,
    required this.price,
    required this.status,
    required this.categoryName,
    this.imageUrl,
    this.description,
  });

  final int dishId;
  final String dishName;
  final double price;
  final DishStatus status;
  final String categoryName;
  final String? imageUrl;
  final String? description;

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      dishId: (json['dishId'] as num?)?.toInt() ?? 0,
      dishName: json['dishName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      status: DishStatus.fromJson(json['status'] as String?),
      imageUrl: _normalizeImageUrl(json['imageUrl'] as String?),
      description: json['description'] as String?,
      categoryName: json['categoryName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dishId': dishId,
      'dishName': dishName,
      'price': price,
      'status': status.toJson(),
      'imageUrl': imageUrl,
      'description': description,
      'categoryName': categoryName,
    };
  }

  static String? _normalizeImageUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://localhost:8080')) {
      return value.replaceFirst(
        'http://localhost:8080',
        ApiConfig.backendOrigin,
      );
    }

    if (value.startsWith('/')) {
      return '${ApiConfig.backendOrigin}$value';
    }

    if (value.startsWith('http')) {
      return value;
    }

    return '${ApiConfig.backendOrigin}/uploads/$value';
  }
}
