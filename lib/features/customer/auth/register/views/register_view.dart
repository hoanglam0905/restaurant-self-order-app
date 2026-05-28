import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../home/views/home_view.dart';
import '../controllers/register_controller.dart';
import '../data/services/register_service.dart';
import '../../login/views/login_view.dart';
import 'widgets/register_card.dart';
import 'widgets/register_footer.dart';
import 'widgets/register_header.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      RegisterController(
        registerService: RegisterService(apiClient: ApiClient()),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<RegisterController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                children: [
                  const RegisterHeader(),
                  const SizedBox(height: 40),
                  RegisterCard(
                    controller: _controller,
                    onSubmit: () => _submit(context),
                    onGoogle: () => _showPendingAction(
                      context,
                      'Đăng ký Google cần luồng idToken.',
                    ),
                    onFacebook: () => _showPendingAction(
                      context,
                      'Đăng ký Facebook chưa có contract backend.',
                    ),
                    onLogin: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                    ),
                  ),
                  const SizedBox(height: 70),
                  const RegisterFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final auth = await _controller.submit();
    if (!context.mounted || auth == null) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeView()),
      (_) => false,
    );
  }

  void _showPendingAction(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.welcomeAccent,
      ),
    );
  }
}
