import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_state_panel.dart';
import '../../../customer/auth/login/views/login_view.dart';
import '../controllers/settings_controller.dart';
import '../data/models/settings_menu_item_model.dart';
import '../data/models/staff_settings_profile_model.dart';
import 'change_password_view.dart';
import 'edit_profile_view.dart';
import 'shift_registration_view.dart';
import 'work_schedule_view.dart';
import 'widgets/settings_info_row.dart';
import 'widgets/settings_menu_tile.dart';
import 'widgets/settings_profile_card.dart';
import 'widgets/settings_section_title.dart';
import 'widgets/settings_summary_tile.dart';

class SettingsManagementView extends StatelessWidget {
  const SettingsManagementView({super.key});

  static const Color _primary = Color(0xFFB84D2D);
  static const Color _pageBackground = Color(0xFFF4F6FB);
  static const Color _surface = Colors.white;
  static const Color _border = Color(0xFFE6E9F1);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFCEFE8), _pageBackground],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -78,
              right: -92,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withValues(alpha: 0.07),
                ),
              ),
            ),
            Column(
              children: [
                const _SettingsHeader(),
                Expanded(
                  child: Obx(() {
                    final profile = controller.profile.value;
                    if (controller.isLoading.value && profile == null) {
                      return const Center(
                        child: CircularProgressIndicator(color: _primary),
                      );
                    }

                    if (controller.errorMessage.value.isNotEmpty &&
                        profile == null) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: AppStatePanel(
                          message: controller.errorMessage.value,
                          actionLabel: 'Thử lại',
                          onAction: controller.loadProfile,
                        ),
                      );
                    }

                    if (profile == null) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: AppStatePanel(
                          message: 'Chưa có dữ liệu hồ sơ nhân viên.',
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: _primary,
                      onRefresh: controller.loadProfile,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                        children: [
                          SettingsProfileCard(profile: profile),
                          const SizedBox(height: 20),
                          const SettingsSectionTitle(
                            title: 'Thông tin cá nhân',
                          ),
                          const SizedBox(height: 10),
                          _buildInfoCard(profile),
                          const SizedBox(height: 18),
                          const SettingsSectionTitle(
                            title: 'Công việc & thu nhập',
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: SettingsSummaryTile(
                                  title: 'Mức lương',
                                  primaryText: profile.salaryDisplay,
                                  secondaryText: 'Theo hợp đồng',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SettingsSummaryTile(
                                  title: 'Ca hiện tại',
                                  primaryText: profile.currentShiftName,
                                  secondaryText: profile.currentShiftTime,
                                  primaryTextColor: const Color(0xFF24262B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const SettingsSectionTitle(
                            title: 'Quản lý tài khoản',
                          ),
                          const SizedBox(height: 10),
                          _buildAccountCard(context, controller),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 54,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFC96541), _primary],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 18,
                                    offset: const Offset(0, 9),
                                    color: _primary.withValues(alpha: 0.32),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginView(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Đăng xuất hệ thống',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              profile.appVersion,
                              style: const TextStyle(
                                color: Color(0xFF9EA3B0),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(StaffSettingsProfileModel profile) {
    return _buildSurfaceCard(
      child: Column(
        children: [
          SettingsInfoRow(
            icon: Icons.alternate_email_rounded,
            label: 'Email liên hệ',
            value: profile.email,
          ),
          const Divider(height: 1, color: Color(0xFFF0F1F6)),
          SettingsInfoRow(
            icon: Icons.phone_outlined,
            label: 'Số điện thoại',
            value: profile.phoneNumber,
          ),
          const Divider(height: 1, color: Color(0xFFF0F1F6)),
          SettingsInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Địa chỉ thường trú',
            value: profile.address,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    SettingsController controller,
  ) {
    return _buildSurfaceCard(
      child: Obx(() {
        final selectedLang = controller.selectedLanguage.value;
        final menuItems = controller.menuItems;

        return Column(
          children: [
            SettingsMenuTile(
              iconCodePoint: menuItems[0].iconCodePoint,
              title: menuItems[0].title,
              onTap: () =>
                  _navigateToFeature(context, controller, menuItems[0]),
            ),
            SettingsMenuTile(
              iconCodePoint: menuItems[1].iconCodePoint,
              title: menuItems[1].title,
              showChevron: menuItems[1].showChevron,
              trailing: _LanguageSwitch(
                selectedValue: selectedLang,
                onChanged: (value) =>
                    _onLanguageChanged(context, controller, value),
              ),
            ),
            SettingsMenuTile(
              iconCodePoint: menuItems[2].iconCodePoint,
              title: menuItems[2].title,
              onTap: () =>
                  _navigateToFeature(context, controller, menuItems[2]),
            ),
            SettingsMenuTile(
              iconCodePoint: menuItems[3].iconCodePoint,
              title: menuItems[3].title,
              onTap: () =>
                  _navigateToFeature(context, controller, menuItems[3]),
            ),
            SettingsMenuTile(
              iconCodePoint: menuItems[4].iconCodePoint,
              title: menuItems[4].title,
              onTap: () =>
                  _navigateToFeature(context, controller, menuItems[4]),
              showDivider: false,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSurfaceCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F111827),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  void _navigateToFeature(
    BuildContext context,
    SettingsController controller,
    SettingsMenuItemModel item,
  ) {
    final profile = controller.profile.value;

    switch (item.id) {
      case 'edit-profile':
        if (profile != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EditProfileView(profile: profile),
            ),
          );
        }
        break;
      case 'work-schedule':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const WorkScheduleView()));
        break;
      case 'register-shift':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ShiftRegistrationView()),
        );
        break;
      case 'security':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ChangePasswordView()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.title} sẽ được hoàn thiện sớm.')),
        );
    }
  }

  void _onLanguageChanged(
    BuildContext context,
    SettingsController controller,
    String value,
  ) {
    controller.changeLanguage(value);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã chuyển sang ngôn ngữ $value.')));
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EAF1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF2E1DA)),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/home/logo_bon_appetit.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hồ sơ & Cài đặt',
                  style: TextStyle(
                    color: Color(0xFF1F2430),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Quản lý thông tin nhân viên',
                  style: TextStyle(
                    color: Color(0xFF8B92A1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF7F8FC),
              border: Border.all(color: const Color(0xFFE2E5ED)),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF767E90),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch({required this.selectedValue, required this.onChanged});

  final String selectedValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE4E7EF)),
      ),
      child: Row(
        children: [
          _LanguagePill(
            label: 'VN',
            selected: selectedValue == 'VN',
            onTap: () => onChanged('VN'),
          ),
          _LanguagePill(
            label: 'EN',
            selected: selectedValue == 'EN',
            onTap: () => onChanged('EN'),
          ),
        ],
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 34,
        height: 26,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE9E2) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x26B84D2D),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFFB84D2D)
                  : const Color(0xFF8B93A2),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
