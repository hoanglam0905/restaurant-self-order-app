import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSessionStorage {
  AuthSessionStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _customerIdKey = 'auth_customer_id';
  static const String _customerNameKey = 'auth_customer_name';

  static const String _staffIdKey = 'auth_staff_id';
  static const String _staffNameKey = 'auth_staff_name';

  static const String _usernameKey = 'auth_username';
  static const String _emailKey = 'auth_email';
  static const String _userTypeKey = 'auth_user_type';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveAuthProfile({
    required String userType,
    int? customerId,
    String? customerName,
    int? staffId,
    String? staffName,
    String? username,
    String? email,
  }) async {
    final normalizedUserType = userType.trim().toUpperCase();

    await _secureStorage.write(key: _userTypeKey, value: normalizedUserType);

    final normalizedUsername = username?.trim();
    if (normalizedUsername == null || normalizedUsername.isEmpty) {
      await _secureStorage.delete(key: _usernameKey);
    } else {
      await _secureStorage.write(key: _usernameKey, value: normalizedUsername);
    }

    final normalizedEmail = email?.trim();
    if (normalizedEmail == null || normalizedEmail.isEmpty) {
      await _secureStorage.delete(key: _emailKey);
    } else {
      await _secureStorage.write(key: _emailKey, value: normalizedEmail);
    }

    if (normalizedUserType == 'CUSTOMER') {
      await clearStaffProfile();

      if (customerId == null || customerId <= 0) {
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

      return;
    }

    if (normalizedUserType == 'STAFF' || normalizedUserType == 'ADMIN') {
      await clearCustomerProfile();

      if (staffId == null || staffId <= 0) {
        await clearStaffProfile();
        return;
      }

      await _secureStorage.write(key: _staffIdKey, value: staffId.toString());

      final normalizedName = staffName?.trim();
      if (normalizedName == null || normalizedName.isEmpty) {
        await _secureStorage.delete(key: _staffNameKey);
      } else {
        await _secureStorage.write(key: _staffNameKey, value: normalizedName);
      }

      return;
    }

    await clearCustomerProfile();
    await clearStaffProfile();
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

  Future<StaffSession?> readStaffSession() async {
    final rawStaffId = await _secureStorage.read(key: _staffIdKey);
    final staffId = int.tryParse(rawStaffId ?? '');
    if (staffId == null || staffId <= 0) {
      return null;
    }

    final staffName = await _secureStorage.read(key: _staffNameKey);
    final username = await _secureStorage.read(key: _usernameKey);
    final email = await _secureStorage.read(key: _emailKey);

    return StaffSession(
      staffId: staffId,
      staffName: staffName,
      username: username,
      email: email,
    );
  }

  Future<String?> readUserType() {
    return _secureStorage.read(key: _userTypeKey);
  }

  Future<void> clearCustomerProfile() async {
    await _secureStorage.delete(key: _customerIdKey);
    await _secureStorage.delete(key: _customerNameKey);
  }

  Future<void> clearStaffProfile() async {
    await _secureStorage.delete(key: _staffIdKey);
    await _secureStorage.delete(key: _staffNameKey);
  }

  Future<void> clear() async {
    await clearCustomerProfile();
    await clearStaffProfile();
    await _secureStorage.delete(key: _usernameKey);
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _userTypeKey);
  }
}

class CustomerSession {
  const CustomerSession({required this.customerId, this.customerName});

  final int customerId;
  final String? customerName;
}

class StaffSession {
  const StaffSession({
    required this.staffId,
    this.staffName,
    this.username,
    this.email,
  });

  final int staffId;
  final String? staffName;
  final String? username;
  final String? email;
}