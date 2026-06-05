class OrderDishModel {
  const OrderDishModel({
    required this.dishId,
    required this.name,
    required this.price,
    required this.status,
    required this.description,
    required this.categoryName,
    this.imageUrl,
  });

  final int dishId;
  final String name;
  final int price;
  final String status;
  final String description;
  final String categoryName;
  final String? imageUrl;

  bool get isAvailable {
    final normalizedStatus = status.trim().toUpperCase();

    return normalizedStatus.isEmpty ||
        normalizedStatus == 'AVAILABLE' ||
        normalizedStatus == 'ACTIVE';
  }

  factory OrderDishModel.fromJson(Map<String, dynamic> json) {
    return OrderDishModel(
      dishId: _parseInt(json['dishId']) ?? 0,
      name: (json['dishName'] ?? json['name'] ?? '').toString(),
      price: _parseInt(json['price']) ?? 0,
      status: (json['status'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      categoryName: (json['categoryName'] ?? 'Khác').toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}