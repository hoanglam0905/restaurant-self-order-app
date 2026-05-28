enum DishStatus {
  available,
  unavailable;

  static DishStatus fromJson(String? value) {
    return switch (value) {
      'AVAILABLE' => DishStatus.available,
      'UNAVAILABLE' => DishStatus.unavailable,
      _ => DishStatus.unavailable,
    };
  }

  String toJson() {
    return switch (this) {
      DishStatus.available => 'AVAILABLE',
      DishStatus.unavailable => 'UNAVAILABLE',
    };
  }
}
