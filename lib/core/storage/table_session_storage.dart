import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TableSessionStorage {
  TableSessionStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _tableIdKey = 'active_table_id';
  static const String _tableLabelKey = 'active_table_label';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveTableSession({
    required int tableId,
    required String tableLabel,
  }) async {
    await _secureStorage.write(key: _tableIdKey, value: tableId.toString());
    await _secureStorage.write(key: _tableLabelKey, value: tableLabel);
  }

  Future<int?> readTableId() async {
    final value = await _secureStorage.read(key: _tableIdKey);
    return int.tryParse(value ?? '');
  }

  Future<String?> readTableLabel() {
    return _secureStorage.read(key: _tableLabelKey);
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _tableIdKey);
    await _secureStorage.delete(key: _tableLabelKey);
  }
}
