import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import 'dish_management/controllers/kitchen_controller.dart';
import 'dish_management/data/services/kitchen_service.dart';
import 'dish_management/views/kitchen_management_view.dart';
import 'history_management/views/history_management_view.dart';
import 'notification_management/views/notification_management_view.dart';
import 'settings_management/controllers/settings_controller.dart';
import 'settings_management/data/services/settings_service.dart';
import 'settings_management/views/settings_management_view.dart';
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

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<TableController>()) {
      Get.put(
        TableController(
          tableService: TableService(ApiClient()),
        ),
      );
    }
    if (!Get.isRegistered<KitchenController>()) {
      Get.put(
        KitchenController(
          kitchenService: KitchenService(),
        ),
      );
    }
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(
        SettingsController(
          settingsService: SettingsService(
            apiClient: ApiClient(),
          ),
        ),
      );
    }
  }

  final List<Widget> _views = const [
    TableManagementView(),
    KitchenManagementView(),
    NotificationManagementView(),
    HistoryManagementView(),
    SettingsManagementView(),
  ];

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF9E3A14);
    const unselectedColor = Color(0xFF718096);
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
