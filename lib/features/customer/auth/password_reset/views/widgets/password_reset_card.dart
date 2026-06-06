import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/widgets/app_auth_text_field.dart';
import '../../../../../../core/widgets/app_back_icon_button.dart';
import '../../../../../../core/widgets/app_cta_button.dart';
import '../../../../../../core/widgets/app_labeled_auth_text_field.dart';
import '../../../../../../core/widgets/app_password_visibility_button.dart';
import '../../controllers/forgot_password_controller.dart';
import '../../controllers/reset_password_controller.dart';

class PasswordResetScaffold extends StatelessWidget {
  const PasswordResetScaffold({
    required this.onBack,
    required this.child,
    super.key,
  });

  final VoidCallback onBack;
  final Widget child;

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
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppBackIconButton(onTap: onBack),
                    ),
                    const SizedBox(height: 70),
                    Image.asset(
                      'assets/images/auth/login_logo.png',
                      width: 196,
                      height: 106,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 48),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordResetCard extends StatelessWidget {
  const PasswordResetCard({
    required this.title,
    required this.description,
    required this.children,
    super.key,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0BFB7)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF161C23),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF5D5E61),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class AppPasswordResetEmailField extends StatelessWidget {
  const AppPasswordResetEmailField({required this.controller, super.key});

  final ForgotPasswordController controller;

  @override
  Widget build(BuildContext context) {
    return AppAuthTextField(
      controller: controller.emailTextController,
      hintText: 'Email',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => controller.submit(),
    );
  }
}

class AppPasswordResetOtpField extends StatelessWidget {
  const AppPasswordResetOtpField({required this.controller, super.key});

  final ResetPasswordController controller;

  @override
  Widget build(BuildContext context) {
    return AppLabeledAuthTextField(
      label: 'Mã xác nhận',
      controller: controller.otpTextController,
      hintText: 'Nhap ma xac nhan',
      prefixIcon: const Icon(
        Icons.pin_outlined,
        color: Color(0xFF8C716A),
        size: 20,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
    );
  }
}

class AppPasswordResetNewPasswordFields extends StatelessWidget {
  const AppPasswordResetNewPasswordFields({
    required this.controller,
    super.key,
  });

  final ResetPasswordController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => AppLabeledAuthTextField(
            label: 'Mật khẩu mới',
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
          ),
        ),
      ],
    );
  }
}

class PasswordResetErrorText extends StatelessWidget {
  const PasswordResetErrorText({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFCC2B00),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PasswordResetSubmitButton extends StatelessWidget {
  const PasswordResetSubmitButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppCtaButton(
      label: label,
      onPressed: onPressed,
      enabled: enabled,
      height: 56,
      borderRadius: 12,
      fontSize: 18,
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
    );
  }
}
