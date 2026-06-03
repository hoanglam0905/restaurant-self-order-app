class TableQrPayload {
  const TableQrPayload({required this.tableId, required this.tableLabel});

  final int tableId;
  final String tableLabel;

  static TableQrPayload? tryParse(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'selfordering') {
      return null;
    }

    final firstPathSegment = uri.pathSegments.isEmpty
        ? null
        : uri.pathSegments.first.toLowerCase();
    final isTableRoute =
        uri.host.toLowerCase() == 'table' || firstPathSegment == 'table';
    if (!isTableRoute) {
      return null;
    }

    final tableId = int.tryParse(uri.queryParameters['tableId'] ?? '');
    if (tableId == null || tableId <= 0) {
      return null;
    }

    final rawLabel = uri.queryParameters['tableLabel']?.trim();
    final tableLabel = rawLabel == null || rawLabel.isEmpty
        ? tableId.toString()
        : rawLabel;

    return TableQrPayload(tableId: tableId, tableLabel: tableLabel);
  }
}
