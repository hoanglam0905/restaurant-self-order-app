import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../controllers/forgot_password_controller.dart';
import '../data/services/password_reset_service.dart';
import 'reset_password_view.dart';
import 'widgets/password_reset_card.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      ForgotPasswordController(
        passwordResetService: PasswordResetService(apiClient: ApiClient()),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<ForgotPasswordController>()) {
        Get.delete<ForgotPasswordController>();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PasswordResetScaffold(
      onBack: () => Navigator.pop(context),
      child: PasswordResetCard(
        title: 'Quên mật khẩu',
        description: 'Nhap email tai khoan. Ma xac nhan mac dinh la 123456.',
        children: [
          AppPasswordResetEmailField(controller: _controller),
          Obx(() {
            if (_controller.errorMessage.value.isEmpty) {
              return const SizedBox(height: 16);
            }

            return PasswordResetErrorText(
              message: _controller.errorMessage.value,
            );
          }),
          Obx(
            () => PasswordResetSubmitButton(
              label: _controller.isLoading.value
                  ? 'Đang gửi mã...'
                  : 'Gửi mã xác nhận',
              enabled: !_controller.isLoading.value,
              onPressed: () => _submit(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final email = await _controller.submit();
    if (!context.mounted || email == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ma xac nhan dat lai mat khau la 123456.'),
        backgroundColor: AppColors.welcomeAccent,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResetPasswordView(email: email)),
    );
  }
}
