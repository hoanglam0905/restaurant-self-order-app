import 'package:get/get.dart';
import '../data/models/staff_table_model.dart';
import '../data/models/table_status.dart';
import '../data/services/table_service.dart';

class TableController extends GetxController {
  TableController({required TableService tableService})
      : _tableService = tableService;

  final TableService _tableService;

  final RxList<StaffTableModel> tables = <StaffTableModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Selected filters
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
      tables.assignAll(fetchedTables);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Summary Metrics
  int get totalTablesCount => tables.length;
  
  int get occupiedTablesCount =>
      tables.where((t) => t.status == TableStatus.occupied).length;

  int get emptyTablesCount =>
      tables.where((t) => t.status == TableStatus.available).length;

  int get occupiedPercentage {
    if (totalTablesCount == 0) return 0;
    return ((occupiedTablesCount / totalTablesCount) * 100).round();
  }

  int get emptyPercentage {
    if (totalTablesCount == 0) return 0;
    return ((emptyTablesCount / totalTablesCount) * 100).round();
  }

  // Filtered Tables
  List<StaffTableModel> get filteredTables {
    return tables.where((table) {
      // 1. Filter by search query (e.g. "T-01" or "1")
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchName = table.tableNumber.toLowerCase().contains(query);
        final matchId = table.id.toString().contains(query);
        if (!matchName && !matchId) return false;
      }

      // 2. Filter by status type
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

      // 3. Filter by Area (for mock realism, let's say odd IDs are in Sảnh, even IDs in VIP/etc. if needed)
      // For now, we show all since it's a mock representation matching the exact image
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

