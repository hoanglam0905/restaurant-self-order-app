import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image_with_fallback.dart';
import '../../../../core/widgets/app_quantity_stepper.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../home/data/models/dish_model.dart';
import '../controllers/restaurant_menu_controller.dart';
import 'widgets/menu_price_formatter.dart';
import 'widgets/menu_top_bar.dart';

class DishDetailView extends StatelessWidget {
  const DishDetailView({
    required this.dish,
    required this.controller,
    super.key,
  });

  final DishModel dish;
  final RestaurantMenuController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.menuSurface,
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              MenuTopBar(
                title: 'View',
                tableLabel: controller.tableLabel,
                onBack: () => Navigator.pop(context),
              ),
              const Divider(height: 1, color: Color(0xFFE0D9D9)),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                  children: [
                    const AppSearchField(
                      hintText: 'Search in menu',
                      readOnly: true,
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: AspectRatio(
                        aspectRatio: 1.02,
                        child: AppImageWithFallback(
                          imageUrl: dish.imageUrl,
                          fallbackAsset: 'assets/images/home/TodaySpecial1.jpg',
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            dish.dishName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        _PricePill(price: dish.price),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF7A43A),
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          '5.0',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            dish.categoryName.isEmpty
                                ? 'Popular'
                                : dish.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (controller.canOrder)
                          _NotePill(onTap: () => _showNoteDialog(context)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      (dish.description == null || dish.description!.isEmpty)
                          ? 'Món ăn được chế biến tươi mới tại nhà hàng.'
                          : dish.description!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: controller.canOrder ? 78 : 30),
                    if (controller.canOrder)
                      _DetailOrderControls(dish: dish, controller: controller)
                    else
                      const _ViewOnlyNotice(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showNoteDialog(BuildContext context) async {
    final textController = TextEditingController(
      text: controller.notes[dish.dishId] ?? '',
    );
    final note = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ghi chú cho ${dish.dishName}'),
          content: TextField(
            controller: textController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: ít cay, không hành...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, textController.text),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
    textController.dispose();
    if (note != null) {
      controller.saveNote(dish, note);
    }
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 89,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F6),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: Text(
          formatMenuPrice(price),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _NotePill extends StatelessWidget {
  const _NotePill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Ink(
          width: 75,
          height: 29,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EEF0),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Center(
            child: Text(
              'Note',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailOrderControls extends StatelessWidget {
  const _DetailOrderControls({required this.dish, required this.controller});

  final DishModel dish;
  final RestaurantMenuController controller;

  @override
  Widget build(BuildContext context) {
    final quantity = controller.quantityFor(dish);
    return Row(
      children: [
        AppQuantityStepper(
          value: quantity,
          onIncrement: () => controller.increment(dish),
          onDecrement: () => controller.decrement(dish),
        ),
        const SizedBox(width: 10),
        Container(
          width: 84,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F1F3),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              formatMenuPrice(dish.price * quantity),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                controller.addDish(dish);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã thêm ${dish.dishName} vào đơn.')),
                );
              },
              child: Ink(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.menuAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 13),
                    Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewOnlyNotice extends StatelessWidget {
  const _ViewOnlyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Bạn đang xem menu. Vui lòng quay lại Home và quét QR bàn để order.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
