import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cta_button.dart';
import '../../../../core/widgets/app_customer_bottom_nav_bar.dart';
import '../../../../core/widgets/app_inline_text_link.dart';
import '../../../../core/widgets/app_state_panel.dart';
import '../../auth/password_reset/views/forgot_password_view.dart';
import '../../home/data/models/table_qr_payload.dart';
import '../../home/views/home_view.dart';
import '../../home/views/table_qr_scan_view.dart';
import '../../menu/views/menu_view.dart';
import '../../order/views/order_history_view.dart';
import '../../welcome/views/welcome_view.dart';
import '../controllers/customer_settings_controller.dart';
import '../data/services/customer_settings_service.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_profile_panel.dart';
import 'widgets/settings_section.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final String _controllerTag;
  late final CustomerSettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = UniqueKey().toString();
    _controller = Get.put(
      CustomerSettingsController(
        settingsService: CustomerSettingsService(ApiClient()),
      ),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    Get.delete<CustomerSettingsController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.menuSurface,
      body: SafeArea(
        child: Obx(
          () => RefreshIndicator(
            onRefresh: _controller.loadSettings,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                const SettingsHeader(),
                const SizedBox(height: 18),
                SettingsProfilePanel(
                  profile: _controller.profile.value,
                  fallbackName: _controller.customerSession.value?.customerName,
                  isLoading: _controller.isLoading.value,
                ),
                if (_controller.errorMessage.value.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  AppStatePanel(
                    message: _controller.errorMessage.value,
                    actionLabel: 'Thử lại',
                    onAction: _controller.loadSettings,
                  ),
                ],
                const SizedBox(height: 22),
                _buildAccountSection(context),
                const SizedBox(height: 20),
                _buildTableSection(context),
                const SizedBox(height: 20),
                _buildRestaurantSection(context),
                const SizedBox(height: 20),
                _buildSessionSection(context),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppCustomerBottomNavBar(
        currentIndex: 4,
        onItemSelected: (index) => _onNavSelected(context, index),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    final profile = _controller.profile.value;
    final joinDateLabel = _joinDateLabel(profile?.joinDate);

    return SettingsSection(
      title: 'Tài khoản',
      children: [
        SettingsActionRow(
          icon: Icons.edit_rounded,
          title: 'Tên hiển thị',
          subtitle: profile == null
              ? 'Đăng nhập để cập nhật hồ sơ khách hàng'
              : 'Cập nhật tên trên hóa đơn và lịch sử đơn',
          onTap: () => _editDisplayName(context),
        ),
        const SettingsDivider(),
        SettingsActionRow(
          icon: Icons.stars_rounded,
          title: '${profile?.points ?? 0} điểm tích lũy',
          subtitle: 'Điểm có thể dùng khi thanh toán hóa đơn sau',
          onTap: () =>
              _showMessage(context, 'Điểm sẽ được áp dụng ở màn thanh toán.'),
        ),
        const SettingsDivider(),
        SettingsActionRow(
          icon: Icons.calendar_month_rounded,
          title: 'Thông tin thành viên',
          subtitle: joinDateLabel,
          onTap: _controller.loadSettings,
        ),
        const SettingsDivider(),
        SettingsActionRow(
          icon: Icons.lock_reset_rounded,
          title: 'Đổi mật khẩu',
          subtitle: 'Dùng luồng quên mật khẩu đã kết nối backend',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForgotPasswordView()),
          ),
        ),
      ],
    );
  }

  Widget _buildTableSection(BuildContext context) {
    final tableId = _controller.tableId.value;
    final tableLabel = _controller.tableLabel.value;
    final hasTable =
        tableId != null && tableLabel != null && tableLabel.isNotEmpty;

    return SettingsSection(
      title: 'Bàn đang order',
      children: [
        SettingsActionRow(
          icon: Icons.qr_code_scanner_rounded,
          title: hasTable ? 'Bàn $tableLabel' : 'Quét QR bàn',
          subtitle: hasTable
              ? 'Table ID $tableId đang được lưu cho phiên gọi món'
              : 'Quét mã selfordering://table?... để xác định bàn',
          onTap: () => _scanTableQr(context),
        ),
        if (hasTable) ...[
          const SettingsDivider(),
          SettingsActionRow(
            icon: Icons.restaurant_menu_rounded,
            title: 'Tiếp tục gọi món',
            subtitle: 'Mở menu order cho bàn $tableLabel',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    MenuView.order(tableId: tableId, tableLabel: tableLabel),
              ),
            ),
          ),
          const SettingsDivider(),
          SettingsActionRow(
            icon: Icons.link_off_rounded,
            title: 'Xóa bàn hiện tại',
            subtitle: 'Dùng khi khách rời bàn hoặc quét nhầm QR',
            isDestructive: true,
            onTap: () => _clearTable(context),
          ),
        ],
      ],
    );
  }

  Widget _buildRestaurantSection(BuildContext context) {
    return SettingsSection(
      title: 'Nhà hàng',
      children: [
        SettingsActionRow(
          icon: Icons.menu_book_rounded,
          title: 'Xem menu',
          subtitle: 'Mở danh sách món ăn không cần chọn bàn',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MenuView.viewOnly()),
          ),
        ),
        const SettingsDivider(),
        SettingsActionRow(
          icon: Icons.history_rounded,
          title: 'Lịch sử đơn hàng',
          subtitle: 'Xem các hóa đơn và trạng thái đơn đã đặt',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderHistoryView()),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionSection(BuildContext context) {
    return SettingsSection(
      title: 'Phiên đăng nhập',
      children: [
        SettingsActionRow(
          icon: Icons.logout_rounded,
          title: _controller.isLoggingOut.value
              ? 'Đang đăng xuất...'
              : 'Đăng xuất',
          subtitle: 'Xóa token, hồ sơ khách và bàn đang lưu trên máy',
          isDestructive: true,
          trailing: _controller.isLoggingOut.value
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: () => _confirmLogout(context),
        ),
      ],
    );
  }

  Future<void> _editDisplayName(BuildContext context) async {
    final profile = _controller.profile.value;
    if (profile == null) {
      _showMessage(context, 'Vui lòng đăng nhập để cập nhật tài khoản.');
      return;
    }

    final currentName = profile.fullName;
    final newName = await _showEditNameDialog(context, currentName);
    if (!context.mounted || newName == null) {
      return;
    }

    final updated = await _controller.updateFullName(newName);
    if (!context.mounted) {
      return;
    }

    _showMessage(
      context,
      updated ? 'Đã cập nhật tên hiển thị.' : _controller.errorMessage.value,
    );
  }

  Future<String?> _showEditNameDialog(
    BuildContext context,
    String currentName,
  ) async {
    final textController = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            'Tên hiển thị',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          content: TextField(
            controller: textController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) =>
                Navigator.pop(dialogContext, textController.text),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppCtaButton(
                  label: 'Lưu thay đổi',
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
    return result;
  }

  Future<void> _scanTableQr(BuildContext context) async {
    final payload = await Navigator.push<TableQrPayload>(
      context,
      MaterialPageRoute(builder: (_) => const TableQrScanView()),
    );
    if (!context.mounted || payload == null) {
      return;
    }

    await _controller.saveTableSession(
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

  Future<void> _clearTable(BuildContext context) async {
    await _controller.clearTableSession();
    if (context.mounted) {
      _showMessage(context, 'Đã xóa bàn đang order.');
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await _showLogoutDialog(context);
    if (!context.mounted || confirmed != true) {
      return;
    }

    final loggedOut = await _controller.logout();
    if (!context.mounted || !loggedOut) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeView()),
      (_) => false,
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            'Đăng xuất?',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Token, thông tin khách hàng và bàn đang order sẽ được xóa khỏi thiết bị này.',
            style: TextStyle(fontSize: 14, height: 1.45),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppCtaButton(
                  label: 'Đăng xuất',
                  onPressed: () => Navigator.pop(dialogContext, true),
                  height: 46,
                  borderRadius: 8,
                  fontSize: 15,
                  backgroundColor: const Color(0xFFC0392B),
                ),
                const SizedBox(height: 10),
                AppInlineTextLink(
                  label: 'Ở lại',
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
  }

  void _onNavSelected(BuildContext context, int index) {
    if (index == 4) {
      return;
    }

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
        (_) => false,
      );
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuView.viewOnly()),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrderHistoryView()),
      );
      return;
    }

    _showMessage(context, 'Tính năng đặt bàn chưa được kết nối.');
  }

  String _joinDateLabel(DateTime? joinDate) {
    if (joinDate == null) {
      return 'Chưa có ngày tham gia trong hồ sơ.';
    }

    return 'Thành viên từ ${joinDate.day}/${joinDate.month}/${joinDate.year}';
  }

  void _showMessage(BuildContext context, String message) {
    if (message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.orderAccent),
    );
  }
}
