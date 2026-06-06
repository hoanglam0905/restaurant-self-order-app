import 'package:get/get.dart';

import '../../dish_management/data/models/staff_kitchen_order_model.dart';
import '../../dish_management/data/services/kitchen_service.dart';
import '../data/models/staff_table_model.dart';
import '../data/models/table_notification_model.dart';
import '../data/models/table_order_model.dart';
import '../data/models/table_status.dart';
import '../data/services/table_service.dart';

class TableController extends GetxController {
  TableController({required TableService tableService})
    : _tableService = tableService;

  final TableService _tableService;
  final KitchenService _kitchenService = KitchenService();

  final RxList<StaffTableModel> tables = <StaffTableModel>[].obs;
  final RxMap<int, List<TableNotificationModel>> tableNotificationsByTableId =
      <int, List<TableNotificationModel>>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString selectedArea = 'Sảnh'.obs;
  final RxString selectedFilterType = 'Tất cả'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTables();
  }

  Future<void> loadTables() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetchedTables = await _tableService.getTables();
      final tableOrders = await _getOrdersForTableStatus();

      List<TableNotificationModel> currentNotifications =
          <TableNotificationModel>[];

      try {
        currentNotifications = await _tableService
            .getCurrentShiftNotifications();
      } catch (_) {
        currentNotifications = <TableNotificationModel>[];
      }

      _cacheNotificationsByTable(currentNotifications);

      final unreadTableIds = currentNotifications
          .where((notification) => !notification.isRead)
          .map((notification) => notification.tableNumber)
          .whereType<int>()
          .toSet();

      tables.assignAll(
        fetchedTables.map((table) {
          final resolvedStatus = _resolveTableStatus(
            table: table,
            orders: tableOrders,
          );

          return table.copyWith(
            status: resolvedStatus,
            hasAlert: unreadTableIds.contains(table.id),
          );
        }).toList(),
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<StaffTableModel?> getTableDetail(int tableId) async {
    isActionLoading.value = true;
    errorMessage.value = '';

    try {
      return await _tableService.getTableById(tableId);
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<StaffKitchenOrderModel?> getActiveOrderByTable(int tableId) async {
    isActionLoading.value = true;
    errorMessage.value = '';

    try {
      final orders = await _kitchenService.getKitchenOrders();

      final tableCode = 'T-${tableId.toString().padLeft(2, '0')}';

      final tableOrders = orders.where((order) {
        return order.tableNumber == tableCode;
      }).toList();

      if (tableOrders.isEmpty) {
        return null;
      }

      tableOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final activeOrders = tableOrders.where((order) {
        return order.status != KitchenOrderStatus.completed;
      }).toList();

      if (activeOrders.isNotEmpty) {
        return activeOrders.first;
      }

      return tableOrders.first;
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<List<TableNotificationModel>> getTableNotifications(
    int tableId,
  ) async {
    isActionLoading.value = true;
    errorMessage.value = '';

    try {
      final notifications = await _tableService.getNotificationsByTable(
        tableId,
      );

      tableNotificationsByTableId[tableId] = notifications;
      _refreshTableAlertsFromCache();

      return notifications;
    } catch (e) {
      final cached = tableNotificationsByTableId[tableId];

      if (cached != null) {
        return cached;
      }

      errorMessage.value = e.toString();
      return <TableNotificationModel>[];
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> markNotificationAsReadAndRefresh(int notificationId) async {
    isActionLoading.value = true;
    errorMessage.value = '';

    try {
      await _tableService.markNotificationAsRead(notificationId);

      _updateCachedNotificationReadStatus(
        notificationId: notificationId,
        isRead: true,
      );

      await loadTables();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> markAllNotificationsAsReadForTable(int tableId) async {
    isActionLoading.value = true;
    errorMessage.value = '';

    try {
      var notifications = tableNotificationsByTableId[tableId];

      notifications ??= await _tableService.getNotificationsByTable(tableId);

      final unreadNotificationIds = notifications
          .where((notification) => !notification.isRead)
          .map((notification) => notification.id)
          .toList();

      if (unreadNotificationIds.isEmpty) {
        await loadTables();
        return true;
      }

      await _tableService.markNotificationsAsRead(unreadNotificationIds);

      tableNotificationsByTableId[tableId] = notifications.map((notification) {
        if (unreadNotificationIds.contains(notification.id)) {
          return notification.copyWith(isRead: true);
        }

        return notification;
      }).toList();

      await loadTables();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> updateTableStatus({
    required int tableId,
    required TableStatus status,
  }) async {
    isActionLoading.value = true;
    errorMessage.value = '';

    try {
      if (status == TableStatus.available) {
        final canRelease = await _canReleaseTable(tableId);
        if (!canRelease) {
          errorMessage.value =
              'Chỉ chuyển bàn trống khi tất cả món đã hoàn tất/hủy và đơn đã thanh toán.';
          return false;
        }
      }

      await _tableService.updateTableStatus(
        tableId: tableId,
        status: status.toJson(),
      );

      await loadTables();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> swapTables({
    required int tableNumberA,
    required int tableNumberB,
  }) async {
    isActionLoading.value = true;
    errorMessage.value = '';

    try {
      await _tableService.swapTables(
        tableNumberA: tableNumberA,
        tableNumberB: tableNumberB,
      );

      await loadTables();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  void _cacheNotificationsByTable(List<TableNotificationModel> notifications) {
    final grouped = <int, List<TableNotificationModel>>{};

    for (final notification in notifications) {
      final tableNumber = notification.tableNumber;

      if (tableNumber == null) continue;

      grouped.putIfAbsent(tableNumber, () => <TableNotificationModel>[]);
      grouped[tableNumber]!.add(notification);
    }

    tableNotificationsByTableId.assignAll(grouped);
  }

  Future<List<TableOrderModel>?> _getOrdersForTableStatus() async {
    try {
      return await _tableService.getOrders();
    } catch (_) {
      return null;
    }
  }

  Future<bool> _canReleaseTable(int tableId) async {
    final orders = await _tableService.getOrders();
    return _resolveTableStatusFromOrders(tableId, orders) ==
        TableStatus.available;
  }

  TableStatus _resolveTableStatus({
    required StaffTableModel table,
    required List<TableOrderModel>? orders,
  }) {
    if (orders == null) {
      return table.status;
    }

    return _resolveTableStatusFromOrders(table.id, orders);
  }

  TableStatus _resolveTableStatusFromOrders(
    int tableId,
    List<TableOrderModel> orders,
  ) {
    final tableOrders = orders
        .where((order) => order.tableNumber == tableId)
        .toList();

    if (tableOrders.isEmpty) {
      return TableStatus.available;
    }

    final hasScheduledReservation = tableOrders.any(
      (order) => order.isScheduledReservation,
    );

    final diningOrders = tableOrders
        .where((order) => !order.isScheduledReservation)
        .toList();

    if (diningOrders.isEmpty) {
      return hasScheduledReservation
          ? TableStatus.reserved
          : TableStatus.available;
    }

    final hasUnreleasedDiningOrder = diningOrders.any(
      (order) => !order.canReleaseTable,
    );

    if (hasUnreleasedDiningOrder) {
      return TableStatus.occupied;
    }

    return hasScheduledReservation
        ? TableStatus.reserved
        : TableStatus.available;
  }

  void _updateCachedNotificationReadStatus({
    required int notificationId,
    required bool isRead,
  }) {
    final updatedMap = <int, List<TableNotificationModel>>{};

    for (final entry in tableNotificationsByTableId.entries) {
      updatedMap[entry.key] = entry.value.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: isRead);
        }

        return notification;
      }).toList();
    }

    tableNotificationsByTableId.assignAll(updatedMap);
    _refreshTableAlertsFromCache();
  }

  void _refreshTableAlertsFromCache() {
    final unreadTableIds = tableNotificationsByTableId.entries
        .where(
          (entry) => entry.value.any((notification) => !notification.isRead),
        )
        .map((entry) => entry.key)
        .toSet();

    tables.assignAll(
      tables.map((table) {
        return table.copyWith(hasAlert: unreadTableIds.contains(table.id));
      }).toList(),
    );
  }

  int get totalTablesCount => tables.length;

  int get occupiedTablesCount =>
      tables.where((table) => table.status == TableStatus.occupied).length;

  int get emptyTablesCount =>
      tables.where((table) => table.status == TableStatus.available).length;

  int get occupiedPercentage {
    if (totalTablesCount == 0) return 0;
    return ((occupiedTablesCount / totalTablesCount) * 100).round();
  }

  int get emptyPercentage {
    if (totalTablesCount == 0) return 0;
    return ((emptyTablesCount / totalTablesCount) * 100).round();
  }

  List<StaffTableModel> get filteredTables {
    return tables.where((table) {
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchName = table.tableNumber.toLowerCase().contains(query);
        final matchId = table.id.toString().contains(query);

        if (!matchName && !matchId) return false;
      }

      if (selectedFilterType.value == 'Bàn trống' &&
          table.status != TableStatus.available) {
        return false;
      }

      if (selectedFilterType.value == 'Bàn có khách' &&
          table.status != TableStatus.occupied) {
        return false;
      }

      if (selectedFilterType.value == 'Đặt trước' &&
          table.status != TableStatus.reserved) {
        return false;
      }

      return true;
    }).toList();
  }

  void changeArea(String area) {
    selectedArea.value = area;
  }

  void changeFilterType(String filterType) {
    selectedFilterType.value = filterType;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
