import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_inline_text_link.dart';
import '../../../home/views/home_view.dart';
import '../../../../staff/staff_navigation_shell.dart';
import '../../data/models/auth_response_model.dart';
import '../../password_reset/views/forgot_password_view.dart';
import '../../register/views/register_view.dart';
import '../controllers/login_controller.dart';
import '../data/services/login_service.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';
import 'widgets/login_social_section.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      LoginController(loginService: LoginService(apiClient: ApiClient())),
    );
  }

  @override
  void dispose() {
    Get.delete<LoginController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 42),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LoginHeader(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 24),
                    LoginForm(
                      controller: _controller,
                      onSubmit: () => _submit(context),
                      onForgotPassword: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordView(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    LoginSocialSection(
                      onGoogle: () => _showPendingAction(
                        context,
                        'Đăng nhập Google cần luồng idToken.',
                      ),
                      onFacebook: () => _showPendingAction(
                        context,
                        'Đăng nhập Facebook chưa có contract backend.',
                      ),
                    ),
                    const SizedBox(height: 56),
                    _RegisterPrompt(
                      onRegister: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterView()),
                      ),
                    ),
                  ],
                ),
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

    final destination = _destinationFor(auth);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (_) => false,
    );
  }

  Widget _destinationFor(AuthResponseModel auth) {
    final userType = auth.userType.toUpperCase();
    if (userType == 'STAFF' || userType == 'ADMIN') {
      return const StaffNavigationShell();
    }
    return const HomeView();
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

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({required this.onRegister});

  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        const Text(
          'Chưa có tài khoản?',
          style: TextStyle(color: Color(0xFF5D5E61), fontSize: 16, height: 1.5),
        ),
        AppInlineTextLink(
          label: 'Đăng ký',
          onTap: onRegister,
          textColor: const Color(0xFFA73413),
          fontSize: 16,
        ),
      ],
    );
  }
}
