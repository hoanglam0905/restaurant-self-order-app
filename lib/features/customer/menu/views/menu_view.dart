import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cta_button.dart';
import '../../../../core/widgets/app_inline_text_link.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_state_panel.dart';
import '../../home/data/models/dish_model.dart';
import '../../home/data/services/home_dish_service.dart';
import '../../order/views/order_detail_view.dart';
import '../controllers/restaurant_menu_controller.dart';
import '../data/services/menu_order_service.dart';
import 'dish_detail_view.dart';
import 'widgets/menu_category_filter.dart';
import 'widgets/menu_dish_tile.dart';
import 'widgets/menu_order_summary_bar.dart';
import 'widgets/menu_price_formatter.dart';
import 'widgets/menu_top_bar.dart';

class MenuView extends StatefulWidget {
  const MenuView.viewOnly({super.key})
    : mode = RestaurantMenuMode.viewOnly,
      tableId = null,
      tableLabel = null;

  const MenuView.order({
    required this.tableId,
    required this.tableLabel,
    super.key,
  }) : mode = RestaurantMenuMode.order;

  final RestaurantMenuMode mode;
  final int? tableId;
  final String? tableLabel;

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  late final String _controllerTag;
  late final RestaurantMenuController _controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = UniqueKey().toString();
    final apiClient = ApiClient();
    _controller = Get.put(
      RestaurantMenuController(
        dishService: HomeDishService(apiClient),
        orderService: MenuOrderService(apiClient),
        mode: widget.mode,
        tableId: widget.tableId,
        tableLabel: widget.tableLabel,
      ),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    Get.delete<RestaurantMenuController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.menuSurface,
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              MenuTopBar(
                title: 'Menu',
                tableLabel: _controller.tableLabel,
                cartCount: _controller.totalItemCount,
                onBack: () => Navigator.pop(context),
                onCartTap:
                    _controller.canOrder && _controller.totalItemCount > 0
                    ? () => _showCartDetails(context)
                    : null,
              ),
              const Divider(height: 1, color: Color(0xFFE9E3E3)),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _controller.loadDishes,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      22,
                      12,
                      _controller.canOrder && _controller.totalItemCount > 0
                          ? 18
                          : 28,
                    ),
                    children: [
                      AppSearchField(
                        controller: _controller.searchTextController,
                        hintText: 'Tìm món trong menu',
                        onChanged: _controller.updateSearch,
                      ),
                      const SizedBox(height: 14),
                      MenuCategoryFilter(
                        categories: _controller.categories,
                        selectedCategory: _controller.selectedCategory.value,
                        onSelected: _controller.selectCategory,
                      ),
                      const SizedBox(height: 18),
                      _buildMenuState(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (!_controller.canOrder || _controller.totalItemCount == 0) {
          return const SizedBox.shrink();
        }

        return MenuOrderSummaryBar(
          controller: _controller,
          onConfirm: () => _confirmOrder(context),
          onDetails: () => _showCartDetails(context),
        );
      }),
    );
  }

  Widget _buildMenuState(BuildContext context) {
    if (_controller.isLoading.value && _controller.dishes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_controller.errorMessage.value.isNotEmpty &&
        _controller.dishes.isEmpty) {
      return AppStatePanel(
        message: _controller.errorMessage.value,
        actionLabel: 'Thử lại',
        onAction: _controller.loadDishes,
      );
    }

    final dishes = _controller.filteredDishes;
    if (dishes.isEmpty) {
      return const AppStatePanel(message: 'Không tìm thấy món phù hợp.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final dish = dishes[index];
        return MenuDishTile(
          dish: dish,
          controller: _controller,
          onView: () => _openDishDetail(context, dish),
          onNote: () => _showNoteDialog(context, dish),
          onOrder: () {
            _controller.addDish(dish);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã thêm ${dish.dishName} vào đơn.')),
            );
          },
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemCount: dishes.length,
    );
  }

  void _openDishDetail(BuildContext context, DishModel dish) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DishDetailView(dish: dish, controller: _controller),
      ),
    );
  }

  Future<void> _showNoteDialog(BuildContext context, DishModel dish) async {
    final textController = TextEditingController(
      text: _controller.notes[dish.dishId] ?? '',
    );

    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            'Ghi chú cho ${dish.dishName}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          content: TextField(
            controller: textController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: ít cay, không hành...',
              border: OutlineInputBorder(),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppCtaButton(
                  label: 'Lưu ghi chú',
                  onPressed: () =>
                      Navigator.pop(dialogContext, textController.text),
                  height: 46,
                  borderRadius: 8,
                  fontSize: 15,
                  backgroundColor: AppColors.orderAccent,
                ),
                const SizedBox(height: 10),
                AppInlineTextLink(
                  label: 'Hủy',
                  onTap: () => Navigator.pop(dialogContext),
                  textColor: AppColors.orderAccent,
                  fontSize: 14,
                ),
              ],
            ),
          ],
        );
      },
    );

    textController.dispose();
    if (note != null) {
      _controller.saveNote(dish, note);
    }
  }

  Future<void> _confirmOrder(BuildContext context) async {
    final orderId = await _controller.submitOrder();
    if (!context.mounted) {
      return;
    }

    if (orderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.errorMessage.value)));
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailView(orderId: orderId)),
    );
  }

  void _showCartDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Obx(
          () => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiết giỏ hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  if (_controller.cartDishes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Giỏ hàng chưa có món.'),
                    )
                  else
                    ..._controller.cartDishes.map((dish) {
                      final quantity = _controller.cartQuantityFor(dish);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dish.dishName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'x$quantity · ${formatMenuPrice(dish.price * quantity, withCurrency: true)}',
                                    style: const TextStyle(
                                      color: AppColors.orderAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _RemoveCartItemAction(
                              onTap: () {
                                _controller.removeDishFromCart(dish);
                                if (_controller.cartDishes.isEmpty) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RemoveCartItemAction extends StatelessWidget {
  const _RemoveCartItemAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFCDC7)),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFB3261E),
            size: 18,
          ),
        ),
      ),
    );
  }
}
