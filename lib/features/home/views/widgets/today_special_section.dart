import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image_with_fallback.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_skeleton_box.dart';
import '../../../../core/widgets/app_state_panel.dart';
import '../../controllers/home_controller.dart';
import '../../data/models/dish_model.dart';

class TodaySpecialSection extends StatelessWidget {
  const TodaySpecialSection({required this.controller, super.key});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: "Today's Special"),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoading.value) {
            return const _SpecialLoadingState();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _SpecialErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.loadDishes,
            );
          }

          final dishes = controller.todaySpecials;
          if (dishes.isEmpty) {
            return const _SpecialEmptyState();
          }

          return SizedBox(
            height: 222,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return SpecialDishCard(
                  dish: dishes[index],
                  fallbackAsset: index.isEven
                      ? 'assets/images/home/TodaySpecial1.jpg'
                      : 'assets/images/home/TodaySpecial2.jpg',
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemCount: dishes.length,
            ),
          );
        }),
      ],
    );
  }
}

class SpecialDishCard extends StatelessWidget {
  const SpecialDishCard({
    required this.dish,
    required this.fallbackAsset,
    super.key,
  });

  final DishModel dish;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 148,
              height: 148,
              color: AppColors.surfaceImage,
              child: AppImageWithFallback(
                imageUrl: dish.imageUrl,
                fallbackAsset: fallbackAsset,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            dish.categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dish.dishName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, height: 1.35),
          ),
          const SizedBox(height: 2),
          Text(
            _formatPrice(dish.price),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }
}

class _SpecialLoadingState extends StatelessWidget {
  const _SpecialLoadingState();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [_DishSkeleton(), SizedBox(width: 12), _DishSkeleton()],
    );
  }
}

class _DishSkeleton extends StatelessWidget {
  const _DishSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: 222,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeletonBox(width: 148, height: 148, radius: 8),
          const SizedBox(height: 12),
          const AppSkeletonBox(width: 54, height: 12),
          const SizedBox(height: 8),
          const AppSkeletonBox(width: 120, height: 14),
          const SizedBox(height: 8),
          const AppSkeletonBox(width: 62, height: 16),
        ],
      ),
    );
  }
}

class _SpecialErrorState extends StatelessWidget {
  const _SpecialErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return AppStatePanel(
      message: message,
      actionLabel: 'Retry',
      onAction: onRetry,
      padding: const EdgeInsets.all(14),
    );
  }
}

class _SpecialEmptyState extends StatelessWidget {
  const _SpecialEmptyState();

  @override
  Widget build(BuildContext context) {
    return const AppStatePanel(message: 'No available dishes today.');
  }
}
