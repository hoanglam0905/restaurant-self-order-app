enum TableStatus {
  available,
  occupied,
  reserved;

  factory TableStatus.fromJson(String? json) {
    if (json == null) return TableStatus.available;
    return switch (json.toUpperCase()) {
      'OCCUPIED' => TableStatus.occupied,
      'AVAILABLE' => TableStatus.available,
      'RESERVED' => TableStatus.reserved,
      _ => TableStatus.available,
    };
  }

  String toJson() => name.toUpperCase();
}
