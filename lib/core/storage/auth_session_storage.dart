import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSessionStorage {
  AuthSessionStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _customerIdKey = 'auth_customer_id';
  static const String _customerNameKey = 'auth_customer_name';
  static const String _userTypeKey = 'auth_user_type';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveAuthProfile({
    required String userType,
    int? customerId,
    String? customerName,
  }) async {
    await _secureStorage.write(key: _userTypeKey, value: userType);

    if (userType.toUpperCase() != 'CUSTOMER' || customerId == null) {
      await clearCustomerProfile();
      return;
    }

    await _secureStorage.write(
      key: _customerIdKey,
      value: customerId.toString(),
    );
    final normalizedName = customerName?.trim();
    if (normalizedName == null || normalizedName.isEmpty) {
      await _secureStorage.delete(key: _customerNameKey);
    } else {
      await _secureStorage.write(key: _customerNameKey, value: normalizedName);
    }
  }

  Future<CustomerSession?> readCustomerSession() async {
    final rawCustomerId = await _secureStorage.read(key: _customerIdKey);
    final customerId = int.tryParse(rawCustomerId ?? '');
    if (customerId == null || customerId <= 0) {
      return null;
    }

    final customerName = await _secureStorage.read(key: _customerNameKey);
    return CustomerSession(customerId: customerId, customerName: customerName);
  }

  Future<void> clearCustomerProfile() async {
    await _secureStorage.delete(key: _customerIdKey);
    await _secureStorage.delete(key: _customerNameKey);
  }

  Future<void> clear() async {
    await clearCustomerProfile();
    await _secureStorage.delete(key: _userTypeKey);
  }
}

class CustomerSession {
  const CustomerSession({required this.customerId, this.customerName});

  final int customerId;
  final String? customerName;
}
