import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/customer_notification_model.dart';

class CustomerSystemNotificationService {
  CustomerSystemNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'customer_order_updates';
  static const String _channelName = 'Customer order updates';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool _isAvailable = true;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _plugin.initialize(settings: settings);
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {
      _isAvailable = false;
    }
    _initialized = true;
  }

  Future<void> show(CustomerNotificationModel notification) async {
    if (kIsWeb || !_isAvailable) {
      return;
    }

    await initialize();
    if (!_isAvailable) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Order, payment, and staff request updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _plugin.show(
        id: notification.id.hashCode & 0x7fffffff,
        title: notification.title,
        body: notification.message,
        notificationDetails: details,
      );
    } catch (_) {
      _isAvailable = false;
    }
  }
}
