import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/storage/table_session_storage.dart';
import '../core/theme/app_theme.dart';
import '../features/customer/home/data/models/table_qr_payload.dart';
import '../features/customer/menu/views/menu_view.dart';
import '../features/customer/notifications/controllers/customer_notification_controller.dart';
import '../features/customer/notifications/views/widgets/customer_notification_host.dart';
import '../features/customer/welcome/views/welcome_view.dart';

class RestaurantApp extends StatefulWidget {
  const RestaurantApp({super.key});

  @override
  State<RestaurantApp> createState() => _RestaurantAppState();
}

class _RestaurantAppState extends State<RestaurantApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final TableSessionStorage _tableSessionStorage = TableSessionStorage();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  String? _lastHandledLink;

  @override
  void initState() {
    super.initState();
    CustomerNotificationController.ensureRegistered();
    _appLinks = AppLinks();
    _listenForTableLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    if (Get.isRegistered<CustomerNotificationController>()) {
      Get.delete<CustomerNotificationController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Bon Appetit',
      theme: AppTheme.light,
      builder: (context, child) =>
          CustomerNotificationHost(child: child ?? const SizedBox.shrink()),
      home: const WelcomeView(),
    );
  }

  void _listenForTableLinks() {
    _appLinks.getInitialLink().then(_handleLink).catchError((_) {});
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      unawaited(_handleLink(uri));
    }, onError: (_) {});
  }

  Future<void> _handleLink(Uri? uri) async {
    if (uri == null) {
      return;
    }

    final rawLink = uri.toString();
    if (_lastHandledLink == rawLink) {
      return;
    }
    _lastHandledLink = rawLink;

    final payload = TableQrPayload.tryParse(rawLink);
    if (payload == null) {
      _showLinkError();
      return;
    }

    await _tableSessionStorage.saveTableSession(
      tableId: payload.tableId,
      tableLabel: payload.tableLabel,
    );
    CustomerNotificationController.refreshActiveSession();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;
      if (navigator == null) {
        return;
      }

      navigator.push(
        MaterialPageRoute(
          builder: (_) => MenuView.order(
            tableId: payload.tableId,
            tableLabel: payload.tableLabel,
          ),
        ),
      );
    });
  }

  void _showLinkError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _navigatorKey.currentContext;
      if (context == null) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ma QR ban khong hop le.')));
    });
  }
}
