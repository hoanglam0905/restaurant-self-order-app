import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/storage/table_session_storage.dart';
import '../../order/data/models/customer_order_websocket_event.dart';
import '../../order/data/services/customer_order_websocket_service.dart';
import '../data/models/customer_notification_model.dart';

class CustomerNotificationController extends GetxController {
  CustomerNotificationController({
    CustomerOrderWebSocketService? webSocketService,
    TableSessionStorage? tableSessionStorage,
  }) : _webSocketService = webSocketService ?? CustomerOrderWebSocketService(),
       _tableSessionStorage = tableSessionStorage ?? TableSessionStorage();

  final CustomerOrderWebSocketService _webSocketService;
  final TableSessionStorage _tableSessionStorage;

  StreamSubscription<CustomerOrderWebSocketEvent>? _subscription;
  Timer? _dismissTimer;
  int? _connectedTableNumber;

  final RxList<CustomerNotificationModel> notifications =
      <CustomerNotificationModel>[].obs;
  final Rxn<CustomerNotificationModel> activeNotification =
      Rxn<CustomerNotificationModel>();
  final RxInt unreadCount = 0.obs;

  static CustomerNotificationController ensureRegistered() {
    if (Get.isRegistered<CustomerNotificationController>()) {
      return Get.find<CustomerNotificationController>();
    }
    return Get.put(CustomerNotificationController(), permanent: true);
  }

  static void refreshActiveSession() {
    if (!Get.isRegistered<CustomerNotificationController>()) {
      return;
    }
    unawaited(Get.find<CustomerNotificationController>().refreshTableSession());
  }

  @override
  void onInit() {
    super.onInit();
    _subscription = _webSocketService.events.listen(_handleRealtimeEvent);
    unawaited(refreshTableSession());
  }

  Future<void> refreshTableSession() async {
    final tableNumber = await _tableSessionStorage.readTableId();
    if (tableNumber == null || tableNumber <= 0) {
      _connectedTableNumber = null;
      await _webSocketService.disconnect();
      return;
    }

    if (_connectedTableNumber == tableNumber) {
      return;
    }

    _connectedTableNumber = tableNumber;
    await _webSocketService.connect(tableNumber);
  }

  void dismissActiveNotification() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    activeNotification.value = null;
  }

  void markAllRead() {
    if (notifications.isEmpty) {
      unreadCount.value = 0;
      return;
    }

    final updated = notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    notifications.assignAll(updated);
    unreadCount.value = 0;
  }

  void clearAll() {
    notifications.clear();
    unreadCount.value = 0;
    dismissActiveNotification();
  }

  void _handleRealtimeEvent(CustomerOrderWebSocketEvent event) {
    if (!event.isOrderUpdate) {
      return;
    }

    final notification = CustomerNotificationModel.fromOrderEvent(event);
    notifications.insert(0, notification);
    if (notifications.length > 30) {
      notifications.removeRange(30, notifications.length);
    }
    unreadCount.value += 1;
    activeNotification.value = notification;
    _dismissTimer?.cancel();
    _dismissTimer = Timer(
      const Duration(seconds: 4),
      dismissActiveNotification,
    );
  }

  @override
  void onClose() {
    _dismissTimer?.cancel();
    _subscription?.cancel();
    unawaited(_webSocketService.dispose());
    super.onClose();
  }
}
