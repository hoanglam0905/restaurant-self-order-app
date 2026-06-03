import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/table_session_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cta_button.dart';
import '../../../../core/widgets/app_customer_bottom_nav_bar.dart';
import '../../../../core/widgets/app_inline_text_link.dart';
import '../../menu/views/menu_view.dart';
import '../../order/views/order_history_view.dart';
import '../../settings/views/settings_view.dart';
import '../controllers/call_staff_controller.dart';
import '../controllers/home_controller.dart';
import '../data/models/table_qr_payload.dart';
import '../data/services/home_dish_service.dart';
import '../data/services/home_notification_service.dart';
import 'table_qr_scan_view.dart';
import 'widgets/home_banner.dart';
import 'widgets/home_delivery_panel.dart';
import 'widgets/home_header.dart';
import 'widgets/home_qr_fab.dart';
import 'widgets/home_reservation_button.dart';
import 'widgets/menu_order_button.dart';
import 'widgets/today_special_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeController _controller;
  late final CallStaffController _callStaffController;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _controller = Get.put(
      HomeController(dishService: HomeDishService(apiClient)),
    );
    _callStaffController = Get.put(
      CallStaffController(
        notificationService: HomeNotificationService(apiClient),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<CallStaffController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.loadDishes,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
            children: [
              const HomeHeader(),
              const SizedBox(height: 8),
              const HomeBanner(),
              const SizedBox(height: 10),
              HomeDeliveryPanel(
                onCallStaff: () => _showCallStaffDialog(context),
              ),
              const SizedBox(height: 8),
              MenuOrderButton(onTap: () => _openViewOnlyMenu(context)),
              const SizedBox(height: 12),
              HomeReservationButton(onTap: () => _showPendingFeature(context)),
              const SizedBox(height: 12),
              TodaySpecialSection(controller: _controller),
            ],
          ),
        ),
      ),
      floatingActionButton: HomeQrFab(onTap: () => _openOrderMenu(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppCustomerBottomNavBar(
        currentIndex: _currentNavIndex,
        onItemSelected: (index) {
          if (index == 0) {
            setState(() => _currentNavIndex = index);
            return;
          }

          if (index == 2) {
            _openViewOnlyMenu(context);
            return;
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderHistoryView()),
            );
            return;
          }

          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsView()),
            );
            return;
          }

          _showPendingFeature(context);
        },
      ),
    );
  }

  void _showPendingFeature(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng này chưa được kết nối.')),
    );
  }

  Future<void> _showCallStaffDialog(BuildContext context) async {
    final requirementController = TextEditingController();
    _callStaffController.errorMessage.value = '';

    final sent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            'Gọi nhân viên',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nhập nhu cầu để nhân viên trong ca nắm rõ trước khi đến bàn.',
                style: TextStyle(
                  color: Color(0xFF5D5E61),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: requirementController,
                minLines: 3,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: cần thêm nước, đổi muỗng, hỗ trợ món...',
                  border: OutlineInputBorder(),
                ),
              ),
              Obx(() {
                if (_callStaffController.errorMessage.value.isEmpty) {
                  return const SizedBox(height: 14);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _callStaffController.errorMessage.value,
                    style: const TextStyle(
                      color: Color(0xFFC0392B),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                );
              }),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => AppCtaButton(
                    label: _callStaffController.isSending.value
                        ? 'Đang gửi...'
                        : 'Gửi yêu cầu',
                    onPressed: () async {
                      final success = await _callStaffController.callStaff(
                        requirementController.text,
                      );
                      if (success && dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    },
                    enabled: !_callStaffController.isSending.value,
                    height: 46,
                    borderRadius: 8,
                    fontSize: 15,
                    backgroundColor: AppColors.orderAccent,
                  ),
                ),
                const SizedBox(height: 10),
                AppInlineTextLink(
                  label: 'Hủy',
                  onTap: () => Navigator.pop(dialogContext, false),
                  textColor: AppColors.orderAccent,
                  fontSize: 14,
                ),
              ],
            ),
          ],
        );
      },
    );

    requirementController.dispose();
    if (!context.mounted || sent != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã gửi yêu cầu gọi nhân viên cho ca trực hiện tại.'),
        backgroundColor: AppColors.orderAccent,
      ),
    );
  }

  void _openViewOnlyMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MenuView.viewOnly()),
    );
  }

  Future<void> _openOrderMenu(BuildContext context) async {
    final payload = await Navigator.push<TableQrPayload>(
      context,
      MaterialPageRoute(builder: (_) => const TableQrScanView()),
    );

    if (!context.mounted || payload == null) {
      return;
    }

    await _openOrderMenuForTable(context, payload);
  }

  Future<void> _openOrderMenuForTable(
    BuildContext context,
    TableQrPayload payload,
  ) async {
    await TableSessionStorage().saveTableSession(
      tableId: payload.tableId,
      tableLabel: payload.tableLabel,
    );

    if (!context.mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenuView.order(
          tableId: payload.tableId,
          tableLabel: payload.tableLabel,
        ),
      ),
    );
  }
}
