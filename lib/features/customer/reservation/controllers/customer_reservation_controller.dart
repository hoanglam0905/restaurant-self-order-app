import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/storage/auth_session_storage.dart';
import '../../home/data/models/dish_model.dart';
import '../../home/data/models/dish_status.dart';
import '../../home/data/services/home_dish_service.dart';
import '../../menu/data/models/order_item_request_model.dart';
import '../../order/data/models/order_detail_model.dart';
import '../data/models/create_reservation_request_model.dart';
import '../data/services/customer_reservation_service.dart';

class CustomerReservationController extends GetxController {
  CustomerReservationController({
    required HomeDishService dishService,
    required CustomerReservationService reservationService,
    AuthSessionStorage? authSessionStorage,
  }) : _dishService = dishService,
       _reservationService = reservationService,
       _authSessionStorage = authSessionStorage ?? AuthSessionStorage();

  final HomeDishService _dishService;
  final CustomerReservationService _reservationService;
  final AuthSessionStorage _authSessionStorage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController tableController = TextEditingController(
    text: '1',
  );
  final TextEditingController noteController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString historyErrorMessage = ''.obs;
  final RxList<DishModel> dishes = <DishModel>[].obs;
  final RxList<OrderDetailModel> reservations = <OrderDetailModel>[].obs;
  final RxMap<int, int> quantities = <int, int>{}.obs;
  final RxInt guestCount = 2.obs;
  final Rx<DateTime> selectedDate = DateTime.now()
      .add(const Duration(days: 1))
      .obs;
  final RxString selectedTime = '18:30'.obs;
  final RxString selectedCategory = 'Tất cả'.obs;

  static const List<String> timeSlots = <String>[
    '11:00',
    '11:30',
    '12:00',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
  ];

  List<DateTime> get availableDates {
    final now = DateTime.now();
    return List<DateTime>.generate(
      7,
      (index) =>
          DateTime(now.year, now.month, now.day).add(Duration(days: index + 1)),
    );
  }

  List<String> get categories {
    final values =
        dishes
            .map((dish) => dish.categoryName.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return <String>['Tất cả', ...values];
  }

  List<DishModel> get filteredDishes {
    return dishes.where((dish) {
      final available = dish.status == DishStatus.available;
      final category = selectedCategory.value;
      final matchesCategory =
          category == 'Tất cả' || dish.categoryName == category;
      return available && matchesCategory;
    }).toList();
  }

  List<DishModel> get selectedDishes {
    return dishes.where((dish) => (quantities[dish.dishId] ?? 0) > 0).toList();
  }

  int get selectedItemCount {
    return quantities.values.fold(0, (total, quantity) => total + quantity);
  }

  double get selectedTotal {
    return selectedDishes.fold(0, (total, dish) {
      return total + dish.price * (quantities[dish.dishId] ?? 0);
    });
  }

  DateTime get reservationDateTime {
    final parts = selectedTime.value.split(':');
    final hour = int.tryParse(parts.first) ?? 18;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final date = selectedDate.value;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';
    historyErrorMessage.value = '';

    try {
      final customerSession = await _authSessionStorage.readCustomerSession();
      final customerName = customerSession?.customerName?.trim();
      if (customerName != null && customerName.isNotEmpty) {
        nameController.text = customerName;
      }

      final loadedDishes = await _dishService.getDishes();
      dishes.assignAll(loadedDishes);
      if (!categories.contains(selectedCategory.value)) {
        selectedCategory.value = 'Tất cả';
      }

      await loadReservationHistory(showLoading: false);
    } on HomeDishException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Không thể tải dữ liệu đặt bàn.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadReservationHistory({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }
    historyErrorMessage.value = '';

    try {
      final history = await _reservationService.getReservationHistory();
      reservations.assignAll(history);
    } on CustomerReservationException catch (error) {
      historyErrorMessage.value = error.message;
    } catch (_) {
      historyErrorMessage.value = 'Không thể tải lịch sử đặt bàn.';
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
  }

  void selectTime(String value) {
    selectedTime.value = value;
  }

  void selectCategory(String value) {
    selectedCategory.value = value;
  }

  void incrementGuests() {
    guestCount.value++;
  }

  void decrementGuests() {
    if (guestCount.value <= 1) {
      return;
    }
    guestCount.value--;
  }

  int quantityFor(DishModel dish) {
    return quantities[dish.dishId] ?? 0;
  }

  void incrementDish(DishModel dish) {
    quantities[dish.dishId] = quantityFor(dish) + 1;
  }

  void decrementDish(DishModel dish) {
    final current = quantityFor(dish);
    if (current <= 1) {
      quantities.remove(dish.dishId);
      return;
    }
    quantities[dish.dishId] = current - 1;
  }

  Future<int?> submitReservation() async {
    final tableId = int.tryParse(tableController.text.trim());
    if (tableId == null || tableId <= 0) {
      errorMessage.value = 'Vui lòng nhập số bàn mong muốn hợp lệ.';
      return null;
    }

    if (!reservationDateTime.isAfter(DateTime.now())) {
      errorMessage.value = 'Vui lòng chọn thời gian đặt bàn trong tương lai.';
      return null;
    }

    final customerSession = await _authSessionStorage.readCustomerSession();
    final rawName = nameController.text.trim();
    if (customerSession == null && rawName.isEmpty) {
      errorMessage.value = 'Vui lòng nhập tên khách hàng.';
      return null;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final request = CreateReservationRequestModel(
        tableId: tableId,
        customerId: customerSession?.customerId,
        customerName: customerSession == null ? rawName : null,
        reservationTime: reservationDateTime,
        notes: _buildReservationNotes(),
        items: selectedDishes.map((dish) {
          return OrderItemRequestModel(
            dishId: dish.dishId,
            quantity: quantities[dish.dishId] ?? 1,
          );
        }).toList(),
      );

      final orderId = await _reservationService.createReservation(request);
      quantities.clear();
      noteController.clear();
      await loadReservationHistory(showLoading: false);
      return orderId;
    } on CustomerReservationException catch (error) {
      errorMessage.value = error.message;
      return null;
    } catch (_) {
      errorMessage.value = 'Không thể gửi yêu cầu đặt bàn.';
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  String _buildReservationNotes() {
    final values = <String>['RESERVATION', 'Số khách: ${guestCount.value}'];

    final phone = phoneController.text.trim();
    if (phone.isNotEmpty) {
      values.add('SĐT: $phone');
    }

    final note = noteController.text.trim();
    if (note.isNotEmpty) {
      values.add('Ghi chú: $note');
    }

    return values.join(' | ');
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    tableController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
