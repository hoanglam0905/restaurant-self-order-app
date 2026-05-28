import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/data/models/dish_model.dart';
import '../../home/data/models/dish_status.dart';
import '../../home/data/services/home_dish_service.dart';
import '../data/models/order_item_request_model.dart';
import '../data/models/order_request_model.dart';
import '../data/services/menu_order_service.dart';

enum RestaurantMenuMode { viewOnly, order }

class RestaurantMenuController extends GetxController {
  RestaurantMenuController({
    required HomeDishService dishService,
    required MenuOrderService orderService,
    required RestaurantMenuMode mode,
    this.tableId,
    this.tableLabel,
  }) : _dishService = dishService,
       _orderService = orderService,
       mode = mode.obs;

  final HomeDishService _dishService;
  final MenuOrderService _orderService;
  final int? tableId;
  final String? tableLabel;
  final Rx<RestaurantMenuMode> mode;

  final TextEditingController searchTextController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString query = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<DishModel> dishes = <DishModel>[].obs;
  final RxMap<int, int> draftQuantities = <int, int>{}.obs;
  final RxMap<int, int> cartQuantities = <int, int>{}.obs;
  final RxMap<int, String> notes = <int, String>{}.obs;

  bool get canOrder =>
      mode.value == RestaurantMenuMode.order && tableId != null;

  List<String> get categories {
    final values =
        dishes
            .map((dish) => dish.categoryName.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...values];
  }

  List<DishModel> get filteredDishes {
    final keyword = query.value.trim().toLowerCase();
    final category = selectedCategory.value;

    return dishes.where((dish) {
      final available = dish.status == DishStatus.available;
      final matchesCategory =
          category == 'All' || dish.categoryName == category;
      final matchesQuery =
          keyword.isEmpty ||
          dish.dishName.toLowerCase().contains(keyword) ||
          (dish.description ?? '').toLowerCase().contains(keyword) ||
          dish.categoryName.toLowerCase().contains(keyword);
      return available && matchesCategory && matchesQuery;
    }).toList();
  }

  List<DishModel> get cartDishes {
    return dishes
        .where((dish) => (cartQuantities[dish.dishId] ?? 0) > 0)
        .toList();
  }

  int get totalItemCount {
    return cartQuantities.values.fold(0, (total, quantity) => total + quantity);
  }

  double get totalAmount {
    return cartDishes.fold(0, (total, dish) {
      return total + dish.price * (cartQuantities[dish.dishId] ?? 0);
    });
  }

  @override
  void onInit() {
    super.onInit();
    loadDishes();
  }

  Future<void> loadDishes() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _dishService.getDishes();
      dishes.assignAll(result);
      if (!categories.contains(selectedCategory.value)) {
        selectedCategory.value = 'All';
      }
    } on HomeDishException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Không thể tải menu.';
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String value) {
    query.value = value;
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  int quantityFor(DishModel dish) {
    return draftQuantities[dish.dishId] ?? cartQuantities[dish.dishId] ?? 1;
  }

  int cartQuantityFor(DishModel dish) {
    return cartQuantities[dish.dishId] ?? 0;
  }

  void increment(DishModel dish) {
    final current = quantityFor(dish);
    draftQuantities[dish.dishId] = current + 1;
  }

  void decrement(DishModel dish) {
    final current = quantityFor(dish);
    if (current <= 1) {
      draftQuantities[dish.dishId] = 1;
      return;
    }
    draftQuantities[dish.dishId] = current - 1;
  }

  void addDish(DishModel dish) {
    if (!canOrder) {
      return;
    }
    cartQuantities[dish.dishId] = quantityFor(dish);
  }

  void saveNote(DishModel dish, String note) {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      notes.remove(dish.dishId);
      return;
    }
    notes[dish.dishId] = trimmed;
  }

  Future<int?> submitOrder() async {
    if (!canOrder || tableId == null) {
      errorMessage.value = 'Vui lòng quét QR bàn trước khi đặt món.';
      return null;
    }

    final items = cartDishes.map((dish) {
      return OrderItemRequestModel(
        dishId: dish.dishId,
        quantity: cartQuantities[dish.dishId] ?? 1,
        notes: notes[dish.dishId],
      );
    }).toList();

    if (items.isEmpty) {
      errorMessage.value = 'Vui lòng chọn ít nhất một món.';
      return null;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final orderId = await _orderService.createOrder(
        OrderRequestModel(
          tableId: tableId!,
          customerName: tableLabel == null ? null : 'Table $tableLabel',
          items: items,
        ),
      );
      draftQuantities.clear();
      cartQuantities.clear();
      notes.clear();
      return orderId;
    } on MenuOrderException catch (error) {
      errorMessage.value = error.message;
      return null;
    } catch (_) {
      errorMessage.value = 'Không thể xác nhận đơn hàng.';
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }
}
