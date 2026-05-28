import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/widgets/app_cta_button.dart';
import '../../../../../../core/widgets/app_labeled_auth_text_field.dart';
import '../../../../../../core/widgets/app_password_visibility_button.dart';
import '../../controllers/register_controller.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    required this.controller,
    required this.onSubmit,
    super.key,
  });

  final RegisterController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppLabeledAuthTextField(
          label: 'Họ và tên',
          controller: controller.fullNameTextController,
          hintText: 'John Doe',
          prefixIcon: const Icon(
            Icons.person_outline_rounded,
            color: Color(0xFF8C716A),
            size: 20,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        AppLabeledAuthTextField(
          label: 'Email',
          controller: controller.emailTextController,
          hintText: 'john@example.com',
          prefixIcon: const Icon(
            Icons.mail_outline_rounded,
            color: Color(0xFF8C716A),
            size: 20,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        AppLabeledAuthTextField(
          label: 'Số điện thoại',
          controller: controller.phoneTextController,
          hintText: '+1 (555) 000-0000',
          prefixIcon: const Icon(
            Icons.phone_outlined,
            color: Color(0xFF8C716A),
            size: 20,
          ),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Obx(
          () => AppLabeledAuthTextField(
            label: 'Mật khẩu',
            controller: controller.passwordTextController,
            hintText: '••••••••',
            obscureText: controller.obscurePassword.value,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF8C716A),
              size: 20,
            ),
            suffixIcon: AppPasswordVisibilityButton(
              obscureText: controller.obscurePassword.value,
              onPressed: controller.togglePasswordVisibility,
            ),
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => AppLabeledAuthTextField(
            label: 'Xác nhận mật khẩu',
            controller: controller.confirmPasswordTextController,
            hintText: '••••••••',
            obscureText: controller.obscureConfirmPassword.value,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF8C716A),
              size: 20,
            ),
            suffixIcon: AppPasswordVisibilityButton(
              obscureText: controller.obscureConfirmPassword.value,
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
          ),
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
            label: controller.isLoading.value ? 'Đang đăng ký...' : 'Đăng ký',
            onPressed: onSubmit,
            enabled: !controller.isLoading.value,
            height: 56,
            borderRadius: 8,
            fontSize: 20,
            backgroundColor: const Color(0xFFA73413),
            trailing: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 22,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                offset: const Offset(0, 4),
                blurRadius: 6,
                spreadRadius: -1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
