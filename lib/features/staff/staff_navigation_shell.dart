import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import 'dish_management/controllers/kitchen_controller.dart';
import 'dish_management/data/services/kitchen_service.dart';
import 'dish_management/views/kitchen_management_view.dart';
import 'notification_management/views/notification_management_view.dart';
import 'table_management/controllers/table_controller.dart';
import 'table_management/data/services/table_service.dart';
import 'table_management/views/table_management_view.dart';

class StaffNavigationShell extends StatefulWidget {
  const StaffNavigationShell({super.key});

  @override
  State<StaffNavigationShell> createState() => _StaffNavigationShellState();
}

class _StaffNavigationShellState extends State<StaffNavigationShell> {
  int _currentIndex = 0;

  // Lazily inject TableController when entering staff flow if it isn't already registered
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<TableController>()) {
      Get.put(TableController(
        tableService: TableService(ApiClient()),
      ));
    }
    if (!Get.isRegistered<KitchenController>()) {
      Get.put(KitchenController(
        kitchenService: KitchenService(),
      ));
    }
  }

  // Views mapping
  final List<Widget> _views = [
    const TableManagementView(),
    const KitchenManagementView(),
    const NotificationManagementView(),
    const _PlaceholderScreen(
      title: 'Lịch sử phục vụ',
      icon: Icons.history_rounded,
      subtitle: 'Lịch sử các đơn đặt món và thanh toán đã phục vụ',
    ),
    const _PlaceholderScreen(
      title: 'Cài đặt hệ thống',
      icon: Icons.settings_rounded,
      subtitle: 'Cài đặt tài khoản, ca trực và thiết bị',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF9E3A14); // Deep rust brown matching mockup
    const unselectedColor = Color(0xFF718096); // Soft blue-grey
    const bottomNavBg = Color(0xFFF8FAFC);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFEDF2F7), width: 1.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: bottomNavBg,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded, size: 22),
              label: 'Sơ đồ bàn',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_rounded, size: 22),
              label: 'Bếp (KDS)',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_rounded, size: 22),
                  // Notification dot on "Phục vụ" matching the mockup
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC62828),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              label: 'Phục vụ',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded, size: 22),
              label: 'Lịch sử',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded, size: 22),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }
}

// Visual placeholder view for tabs that are pending implementation
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  final String title;
  final IconData icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF9E3A14);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                      ),
                      child: Icon(
                        icon,
                        size: 64,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
