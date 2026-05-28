import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_image_with_fallback.dart';
import '../../../home/data/models/dish_model.dart';
import '../../controllers/restaurant_menu_controller.dart';
import 'menu_price_formatter.dart';

class MenuOrderSummaryBar extends StatelessWidget {
  const MenuOrderSummaryBar({
    required this.controller,
    required this.onConfirm,
    required this.onDetails,
    super.key,
  });

  final RestaurantMenuController controller;
  final VoidCallback onConfirm;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final dishes = controller.cartDishes;

    return Container(
      height: 140,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1DADA))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          child: Column(
            children: [
              Row(
                children: [
                  _CartPreview(
                    dishes: dishes,
                    total: controller.totalItemCount,
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: onDetails,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Xem chi tiết',
                              style: TextStyle(
                                color: AppColors.orderAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: AppColors.orderAccent,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Tổng cộng',
                    style: TextStyle(
                      color: Color(0xFF7F7F7F),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    ' (${controller.totalItemCount} món)',
                    style: const TextStyle(
                      color: Color(0xFF7F7F7F),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatMenuPrice(controller.totalAmount, withCurrency: true),
                    style: const TextStyle(
                      color: AppColors.orderAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 162,
                height: 38,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(7),
                    onTap: controller.isSubmitting.value ? null : onConfirm,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: AppColors.orderAccent,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orderAccent.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 7),
                                  Text(
                                    'XÁC NHẬN ĐƠN HÀNG',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartPreview extends StatelessWidget {
  const _CartPreview({required this.dishes, required this.total});

  final List<DishModel> dishes;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 2,
            child: CircleAvatar(
              radius: 11,
              backgroundColor: AppColors.orderAccent,
              child: Text(
                total.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          for (var index = 0; index < dishes.take(3).length; index++)
            Positioned(
              left: 19.0 + index * 16,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: AppImageWithFallback(
                    imageUrl: dishes[index].imageUrl,
                    fallbackAsset: 'assets/images/home/TodaySpecial1.jpg',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
