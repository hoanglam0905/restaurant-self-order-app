import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/table_session_storage.dart';
import '../../order/data/models/customer_order_websocket_event.dart';
import '../../order/data/services/customer_order_websocket_service.dart';
import '../data/models/customer_notification_model.dart';
import '../data/services/customer_notification_storage.dart';
import '../data/services/customer_staff_request_notification_service.dart';
import '../data/services/customer_system_notification_service.dart';

class CustomerNotificationController extends GetxController
    with WidgetsBindingObserver {
  CustomerNotificationController({
    CustomerOrderWebSocketService? webSocketService,
    TableSessionStorage? tableSessionStorage,
    CustomerNotificationStorage? notificationStorage,
    CustomerStaffRequestNotificationService? staffRequestService,
    CustomerSystemNotificationService? systemNotificationService,
  }) : _webSocketService = webSocketService ?? CustomerOrderWebSocketService(),
       _tableSessionStorage = tableSessionStorage ?? TableSessionStorage(),
       _notificationStorage =
           notificationStorage ?? CustomerNotificationStorage(),
       _staffRequestService =
           staffRequestService ??
           CustomerStaffRequestNotificationService(ApiClient()),
       _systemNotificationService =
           systemNotificationService ?? CustomerSystemNotificationService();

  final CustomerOrderWebSocketService _webSocketService;
  final TableSessionStorage _tableSessionStorage;
  final CustomerNotificationStorage _notificationStorage;
  final CustomerStaffRequestNotificationService _staffRequestService;
  final CustomerSystemNotificationService _systemNotificationService;

  StreamSubscription<CustomerOrderWebSocketEvent>? _subscription;
  Timer? _dismissTimer;
  Timer? _staffRequestPollTimer;
  int? _connectedTableNumber;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

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
    WidgetsBinding.instance.addObserver(this);
    _subscription = _webSocketService.events.listen(_handleRealtimeEvent);
    unawaited(_systemNotificationService.initialize());
    unawaited(_loadSavedNotifications());
    unawaited(refreshTableSession());
  }

  Future<void> refreshTableSession() async {
    await _loadSavedNotifications();
    final tableNumber = await _tableSessionStorage.readTableId();
    if (tableNumber == null || tableNumber <= 0) {
      _connectedTableNumber = null;
      _stopStaffRequestPolling();
      await _webSocketService.disconnect();
      return;
    }

    if (_connectedTableNumber == tableNumber) {
      return;
    }

    _connectedTableNumber = tableNumber;
    await _webSocketService.connect(tableNumber);
    _startStaffRequestPolling(tableNumber);
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
    unawaited(_saveNotifications());
  }

  void clearAll() {
    notifications.clear();
    unreadCount.value = 0;
    dismissActiveNotification();
    unawaited(_saveNotifications());
  }

  void addStaffRequestHandledNotification(
    CustomerNotificationModel notification,
  ) {
    _addNotification(notification, showPopup: true);
  }

  void _handleRealtimeEvent(CustomerOrderWebSocketEvent event) {
    if (!event.isOrderUpdate) {
      return;
    }

    final notification = CustomerNotificationModel.fromOrderEvent(event);
    _addNotification(notification, showPopup: true);
  }

  void _addNotification(
    CustomerNotificationModel notification, {
    required bool showPopup,
  }) {
    notifications.insert(0, notification);
    if (notifications.length > 30) {
      notifications.removeRange(30, notifications.length);
    }
    unreadCount.value += 1;
    unawaited(_saveNotifications());
    if (_lifecycleState != AppLifecycleState.resumed) {
      unawaited(_systemNotificationService.show(notification));
    }
    if (showPopup) {
      activeNotification.value = notification;
      _dismissTimer?.cancel();
      _dismissTimer = Timer(
        const Duration(seconds: 4),
        dismissActiveNotification,
      );
    }
  }

  Future<void> _loadSavedNotifications() async {
    final saved = await _notificationStorage.loadNotifications();
    notifications.assignAll(saved.take(30));
    unreadCount.value = saved
        .where((notification) => !notification.isRead)
        .length;
  }

  Future<void> _saveNotifications() {
    return _notificationStorage.saveNotifications(notifications.toList());
  }

  void _startStaffRequestPolling(int tableNumber) {
    _staffRequestPollTimer?.cancel();
    _staffRequestPollTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      unawaited(_pollHandledStaffRequests(tableNumber));
    });
    unawaited(_pollHandledStaffRequests(tableNumber));
  }

  void _stopStaffRequestPolling() {
    _staffRequestPollTimer?.cancel();
    _staffRequestPollTimer = null;
  }

  Future<void> _pollHandledStaffRequests(int tableNumber) async {
    final handledIds = await _notificationStorage
        .loadHandledRemoteNotificationIds(tableNumber);
    final remoteNotifications = await _staffRequestService
        .getTableNotifications(tableNumber);

    var changed = false;
    for (final remote in remoteNotifications) {
      if (remote.notificationId <= 0 ||
          !remote.isHandledStaffRequest ||
          handledIds.contains(remote.notificationId)) {
        continue;
      }

      handledIds.add(remote.notificationId);
      changed = true;
      _addNotification(
        CustomerNotificationModel.fromHandledStaffRequest(remote),
        showPopup: true,
      );
    }

    if (changed) {
      await _notificationStorage.saveHandledRemoteNotificationIds(
        tableNumber: tableNumber,
        notificationIds: handledIds,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _dismissTimer?.cancel();
    _stopStaffRequestPolling();
    _subscription?.cancel();
    unawaited(_webSocketService.dispose());
    super.onClose();
  }
}
