import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_icon_button.dart';
import '../../../../core/widgets/app_cta_button.dart';
import '../../../../core/widgets/app_quantity_stepper.dart';
import '../../../../core/widgets/app_state_panel.dart';
import '../../home/data/services/home_dish_service.dart';
import '../controllers/customer_reservation_controller.dart';
import '../data/services/customer_reservation_service.dart';
import 'widgets/customer_reservation_history_card.dart';
import 'widgets/reservation_dish_tile.dart';

class CustomerReservationView extends StatefulWidget {
  const CustomerReservationView({super.key});

  @override
  State<CustomerReservationView> createState() =>
      _CustomerReservationViewState();
}

class _CustomerReservationViewState extends State<CustomerReservationView> {
  late final String _controllerTag;
  late final CustomerReservationController _controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = UniqueKey().toString();
    final apiClient = ApiClient();
    _controller = Get.put(
      CustomerReservationController(
        dishService: HomeDishService(apiClient),
        reservationService: CustomerReservationService(apiClient),
      ),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    Get.delete<CustomerReservationController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.menuSurface,
        body: SafeArea(
          child: Column(
            children: [
              _ReservationHeader(onBack: () => Navigator.maybePop(context)),
              const TabBar(
                labelColor: AppColors.orderAccent,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.orderAccent,
                labelStyle: TextStyle(fontWeight: FontWeight.w900),
                tabs: [
                  Tab(text: 'Đặt bàn'),
                  Tab(text: 'Lịch sử'),
                ],
              ),
              Expanded(
                child: Obx(
                  () => TabBarView(
                    children: [
                      _buildReservationForm(context),
                      _buildReservationHistory(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationForm(BuildContext context) {
    if (_controller.isLoading.value && _controller.dishes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _controller.loadInitialData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          const Text(
            'Thông tin đặt bàn',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chọn thời gian, bàn mong muốn và món ăn đặt trước nếu cần.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          _buildContactFields(),
          const SizedBox(height: 18),
          _buildDateSelector(),
          const SizedBox(height: 16),
          _buildTimeSelector(),
          const SizedBox(height: 18),
          _buildGuestAndTablePanel(),
          const SizedBox(height: 18),
          _buildNoteField(),
          const SizedBox(height: 20),
          _buildDishSection(),
          if (_controller.errorMessage.value.isNotEmpty) ...[
            const SizedBox(height: 14),
            AppStatePanel(message: _controller.errorMessage.value),
          ],
          const SizedBox(height: 18),
          AppCtaButton(
            label: _controller.isSubmitting.value
                ? 'Đang gửi yêu cầu...'
                : 'Xác nhận đặt bàn',
            onPressed: () => _submitReservation(context),
            enabled: !_controller.isSubmitting.value,
            backgroundColor: AppColors.orderAccent,
            height: 50,
            borderRadius: 8,
            fontSize: 14,
            trailing: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        TextField(
          controller: _controller.nameController,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Tên khách hàng',
            icon: Icons.person_outline_rounded,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _controller.phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            label: 'Số điện thoại',
            icon: Icons.phone_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Chọn ngày'),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _controller.availableDates.map((date) {
              final selected = _isSameDay(date, _controller.selectedDate.value);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: selected,
                  onSelected: (_) => _controller.selectDate(date),
                  selectedColor: AppColors.orderAccent,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected
                        ? AppColors.orderAccent
                        : const Color(0xFFE6DCD9),
                  ),
                  label: SizedBox(
                    width: 54,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _weekday(date),
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          date.day.toString().padLeft(2, '0'),
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Chọn khung giờ'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CustomerReservationController.timeSlots.map((slot) {
            final selected = _controller.selectedTime.value == slot;
            return ChoiceChip(
              selected: selected,
              selectedColor: AppColors.orderAccent,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected
                    ? AppColors.orderAccent
                    : const Color(0xFFE6DCD9),
              ),
              label: SizedBox(
                width: 60,
                child: Text(
                  slot,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              onSelected: (_) => _controller.selectTime(slot),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGuestAndTablePanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEDE4E1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller.tableController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                label: 'Bàn mong muốn',
                icon: Icons.table_restaurant_outlined,
                compact: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Số khách',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              AppQuantityStepper(
                value: _controller.guestCount.value,
                compact: true,
                onIncrement: _controller.incrementGuests,
                onDecrement: _controller.decrementGuests,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _controller.noteController,
      minLines: 3,
      maxLines: 4,
      decoration: _inputDecoration(
        label: 'Ghi chú thêm',
        icon: Icons.edit_note_rounded,
      ),
    );
  }

  Widget _buildDishSection() {
    if (_controller.errorMessage.value.isNotEmpty &&
        _controller.dishes.isEmpty) {
      return AppStatePanel(
        message: _controller.errorMessage.value,
        actionLabel: 'Thử lại',
        onAction: _controller.loadInitialData,
      );
    }

    if (_controller.dishes.isEmpty) {
      return const AppStatePanel(message: 'Chưa có món khả dụng để đặt trước.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle('Món ăn đặt trước')),
            if (_controller.selectedItemCount > 0)
              Text(
                '${_controller.selectedItemCount} món',
                style: const TextStyle(
                  color: AppColors.orderAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _controller.categories.map((category) {
              final selected = _controller.selectedCategory.value == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: selected,
                  selectedColor: AppColors.orderAccent,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected
                        ? AppColors.orderAccent
                        : const Color(0xFFE6DCD9),
                  ),
                  label: Text(
                    category,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onSelected: (_) => _controller.selectCategory(category),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (_controller.filteredDishes.isEmpty)
          const AppStatePanel(message: 'Không có món trong nhóm này.')
        else
          ..._controller.filteredDishes.take(8).map((dish) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReservationDishTile(
                dish: dish,
                quantity: _controller.quantityFor(dish),
                onIncrement: () => _controller.incrementDish(dish),
                onDecrement: () => _controller.decrementDish(dish),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildReservationHistory() {
    if (_controller.isLoading.value && _controller.reservations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.historyErrorMessage.value.isNotEmpty &&
        _controller.reservations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AppStatePanel(
          message: _controller.historyErrorMessage.value,
          actionLabel: 'Thử lại',
          onAction: _controller.loadReservationHistory,
        ),
      );
    }

    if (_controller.reservations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: AppStatePanel(message: 'Bạn chưa có lịch sử đặt bàn.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.loadReservationHistory,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemBuilder: (context, index) {
          return CustomerReservationHistoryCard(
            order: _controller.reservations[index],
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemCount: _controller.reservations.length,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    bool compact = false,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: AppColors.orderAccent),
      filled: true,
      fillColor: Colors.white,
      isDense: compact,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEDE4E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEDE4E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.orderAccent),
      ),
    );
  }

  Widget _sectionTitle(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _weekday(DateTime date) {
    return switch (date.weekday) {
      DateTime.monday => 'T2',
      DateTime.tuesday => 'T3',
      DateTime.wednesday => 'T4',
      DateTime.thursday => 'T5',
      DateTime.friday => 'T6',
      DateTime.saturday => 'T7',
      _ => 'CN',
    };
  }

  Future<void> _submitReservation(BuildContext context) async {
    final orderId = await _controller.submitReservation();
    if (!context.mounted) {
      return;
    }

    if (orderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.errorMessage.value)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã gửi yêu cầu đặt bàn #$orderId.'),
        backgroundColor: AppColors.orderAccent,
      ),
    );

    DefaultTabController.of(context).animateTo(1);
  }
}

class _ReservationHeader extends StatelessWidget {
  const _ReservationHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      child: Row(
        children: [
          AppBackIconButton(onTap: onBack),
          const Expanded(
            child: Text(
              'Đặt bàn',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}
