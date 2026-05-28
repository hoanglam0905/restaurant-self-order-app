import 'package:get/get.dart';

import '../data/models/dish_model.dart';
import '../data/models/dish_status.dart';
import '../data/services/home_dish_service.dart';

class HomeController extends GetxController {
  HomeController({required HomeDishService dishService})
    : _dishService = dishService;

  final HomeDishService _dishService;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<DishModel> dishes = <DishModel>[].obs;

  static const String customerName = 'Quý khách';
  static const String tableCode = 'A6';

  List<DishModel> get todaySpecials {
    return dishes
        .where((dish) => dish.status == DishStatus.available)
        .take(6)
        .toList();
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
    } on HomeDishException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = 'Could not load dishes.';
    } finally {
      isLoading.value = false;
    }
  }
}
