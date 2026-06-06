import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/storage/auth_session_storage.dart';
import '../../../../../core/storage/table_session_storage.dart';
import '../models/customer_notification_model.dart';

class CustomerNotificationStorage {
  CustomerNotificationStorage({
    AuthSessionStorage? authSessionStorage,
    TableSessionStorage? tableSessionStorage,
  }) : _authSessionStorage = authSessionStorage ?? AuthSessionStorage(),
       _tableSessionStorage = tableSessionStorage ?? TableSessionStorage();

  final AuthSessionStorage _authSessionStorage;
  final TableSessionStorage _tableSessionStorage;

  Future<List<CustomerNotificationModel>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(await _notificationsKey());
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map((item) => CustomerNotificationModel.fromJson(item))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveNotifications(
    List<CustomerNotificationModel> notifications,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      notifications.map((notification) => notification.toJson()).toList(),
    );
    await prefs.setString(await _notificationsKey(), encoded);
  }

  Future<Set<int>> loadHandledRemoteNotificationIds(int tableNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
            .getStringList(_handledRequestsKey(tableNumber))
            ?.map(int.tryParse)
            .whereType<int>()
            .toSet() ??
        <int>{};
  }

  Future<void> saveHandledRemoteNotificationIds({
    required int tableNumber,
    required Set<int> notificationIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _handledRequestsKey(tableNumber),
      notificationIds.map((id) => id.toString()).toList(),
    );
  }

  Future<String> _notificationsKey() async {
    final customerSession = await _authSessionStorage.readCustomerSession();
    if (customerSession != null) {
      return 'customer_notifications_v1_customer_${customerSession.customerId}';
    }

    final tableNumber = await _tableSessionStorage.readTableId();
    if (tableNumber != null && tableNumber > 0) {
      return 'customer_notifications_v1_table_$tableNumber';
    }

    return 'customer_notifications_v1_guest';
  }

  String _handledRequestsKey(int tableNumber) {
    return 'customer_notifications_v1_handled_staff_requests_$tableNumber';
  }
}
