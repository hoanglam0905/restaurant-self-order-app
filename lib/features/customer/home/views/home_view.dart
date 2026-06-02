import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/table_session_storage.dart';
import '../../../../core/widgets/app_customer_bottom_nav_bar.dart';
import '../../menu/views/menu_view.dart';
import '../../order/views/order_history_view.dart';
import '../controllers/home_controller.dart';
import '../data/services/home_dish_service.dart';
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
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      HomeController(dishService: HomeDishService(ApiClient())),
    );
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
              const HomeDeliveryPanel(),
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

  void _openViewOnlyMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MenuView.viewOnly()),
    );
  }

  Future<void> _openOrderMenu(BuildContext context) async {
    const tableId = 3;
    const tableLabel = HomeController.tableCode;
    await TableSessionStorage().saveTableSession(
      tableId: tableId,
      tableLabel: tableLabel,
    );

    if (!context.mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const MenuView.order(tableId: tableId, tableLabel: tableLabel),
      ),
    );
  }
}
