import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../controllers/reset_password_controller.dart';
import '../data/services/password_reset_service.dart';
import '../../login/views/login_view.dart';
import 'widgets/password_reset_card.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({required this.email, super.key});

  final String email;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  late final ResetPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      ResetPasswordController(
        passwordResetService: PasswordResetService(apiClient: ApiClient()),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<ResetPasswordController>()) {
        Get.delete<ResetPasswordController>();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PasswordResetScaffold(
      onBack: () => Navigator.pop(context),
      child: PasswordResetCard(
        title: 'Đặt lại mật khẩu',
        description:
            'Nhap ma xac nhan da duoc gui den ${widget.email} va mat khau moi.',
        children: [
          AppPasswordResetOtpField(controller: _controller),
          const SizedBox(height: 16),
          AppPasswordResetNewPasswordFields(controller: _controller),
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
                  ? 'Đang cập nhật...'
                  : 'Đặt lại mật khẩu',
              enabled: !_controller.isLoading.value,
              onPressed: () => _submit(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final success = await _controller.submit();
    if (!context.mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mật khẩu đã được cập nhật. Vui lòng đăng nhập lại.'),
        backgroundColor: AppColors.welcomeAccent,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }
}
