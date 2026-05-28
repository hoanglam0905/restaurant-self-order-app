import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/customer/welcome/views/welcome_view.dart';

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bon Appetit',
      theme: AppTheme.light,
      home: const WelcomeView(),
    );
  }
}
