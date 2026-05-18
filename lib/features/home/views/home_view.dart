import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../controllers/home_controller.dart';
import '../data/services/home_dish_service.dart';
import 'widgets/home_banner.dart';
import 'widgets/home_delivery_panel.dart';
import 'widgets/home_header.dart';
import 'widgets/menu_order_button.dart';
import 'widgets/today_special_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeController _controller;

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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.loadDishes,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              const HomeHeader(),
              const SizedBox(height: 10),
              const HomeBanner(),
              const SizedBox(height: 18),
              const HomeDeliveryPanel(),
              const SizedBox(height: 20),
              MenuOrderButton(onTap: () => _showPendingFeature(context)),
              const SizedBox(height: 18),
              TodaySpecialSection(controller: _controller),
            ],
          ),
        ),
      ),
    );
  }

  void _showPendingFeature(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menu and orders screen is not connected yet.'),
      ),
    );
  }
}
