import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/widgets/app_auth_text_field.dart';
import '../../../../../../core/widgets/app_checkbox_label.dart';
import '../../../../../../core/widgets/app_cta_button.dart';
import '../../../../../../core/widgets/app_inline_text_link.dart';
import '../../../../../../core/widgets/app_password_visibility_button.dart';
import '../../controllers/login_controller.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    required this.controller,
    required this.onSubmit,
    required this.onForgotPassword,
    super.key,
  });

  final LoginController controller;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppAuthTextField(
          controller: controller.loginTextController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Obx(
          () => AppAuthTextField(
            controller: controller.passwordTextController,
            hintText: 'Mật khẩu',
            obscureText: controller.obscurePassword.value,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            suffixIcon: AppPasswordVisibilityButton(
              obscureText: controller.obscurePassword.value,
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => AppCheckboxLabel(
                value: controller.rememberMe.value,
                label: 'Ghi nhớ tôi',
                onChanged: controller.toggleRememberMe,
              ),
            ),
            AppInlineTextLink(
              label: 'Quên mật khẩu?',
              onTap: onForgotPassword,
              textColor: const Color(0xFFA73413),
              fontSize: 12,
            ),
          ],
        ),
        Obx(() {
          if (controller.errorMessage.value.isEmpty) {
            return const SizedBox(height: 16);
          }

          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(
                  color: Color(0xFFCC2B00),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
        Obx(
          () => AppCtaButton(
            label: controller.isLoading.value
                ? 'Đang đăng nhập...'
                : 'Đăng nhập',
            onPressed: onSubmit,
            enabled: !controller.isLoading.value,
            height: 56,
            borderRadius: 12,
            fontSize: 20,
            backgroundColor: const Color(0xFFA73413),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFD06A49), Color(0xFFA72C0A)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA73413).withValues(alpha: 0.20),
                offset: const Offset(0, 4),
                blurRadius: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
