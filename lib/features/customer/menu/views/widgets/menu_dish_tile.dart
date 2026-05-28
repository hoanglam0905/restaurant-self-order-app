import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_image_with_fallback.dart';
import '../../../../../core/widgets/app_quantity_stepper.dart';
import '../../../home/data/models/dish_model.dart';
import '../../controllers/restaurant_menu_controller.dart';
import 'menu_price_formatter.dart';

class MenuDishTile extends StatelessWidget {
  const MenuDishTile({
    required this.dish,
    required this.controller,
    required this.onView,
    required this.onNote,
    required this.onOrder,
    super.key,
  });

  final DishModel dish;
  final RestaurantMenuController controller;
  final VoidCallback onView;
  final VoidCallback onNote;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    final canOrder = controller.canOrder;

    return SizedBox(
      height: canOrder ? 92 : 82,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 82,
              height: 82,
              child: AppImageWithFallback(
                imageUrl: dish.imageUrl,
                fallbackAsset: 'assets/images/home/TodaySpecial1.jpg',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EEF0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        formatMenuPrice(dish.price, withCurrency: true),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF7A43A),
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '5.0',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        dish.categoryName.isEmpty
                            ? 'Popular'
                            : dish.categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    _SmallActionButton(
                      label: 'View',
                      icon: null,
                      onTap: onView,
                      backgroundColor: AppColors.menuAccent,
                    ),
                    if (canOrder) ...[
                      const SizedBox(width: 12),
                      _SmallActionButton(
                        label: 'Order',
                        icon: Icons.receipt_long_rounded,
                        onTap: onOrder,
                        backgroundColor: AppColors.menuAccent,
                      ),
                    ] else ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Quét QR để order',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (canOrder) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 58,
              child: Column(
                children: [
                  _NoteButton(onTap: onNote),
                  const SizedBox(height: 8),
                  AppQuantityStepper(
                    value: controller.quantityFor(dish),
                    compact: true,
                    onIncrement: () => controller.increment(dish),
                    onDecrement: () => controller.decrement(dish),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Ink(
          width: icon == null ? 49 : 83,
          height: 26,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 15),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteButton extends StatelessWidget {
  const _NoteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Ink(
          width: 49,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFF2EEF0),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Center(
            child: Text(
              'Note',
              style: TextStyle(
                color: Colors.black,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
