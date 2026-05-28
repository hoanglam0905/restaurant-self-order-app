import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/reset_password_request_model.dart';
import '../data/services/password_reset_service.dart';

class ResetPasswordController extends GetxController {
  ResetPasswordController({required PasswordResetService passwordResetService})
    : _passwordResetService = passwordResetService;

  final PasswordResetService _passwordResetService;

  final TextEditingController otpTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController confirmPasswordTextController =
      TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString errorMessage = ''.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<bool> submit() async {
    final otp = otpTextController.text.trim();
    final password = passwordTextController.text;
    final confirmPassword = confirmPasswordTextController.text;

    if (otp.isEmpty || password.isEmpty) {
      errorMessage.value = 'Vui lòng nhập mã xác nhận và mật khẩu mới.';
      return false;
    }

    if (password.length < 8) {
      errorMessage.value = 'Mật khẩu phải có ít nhất 8 ký tự.';
      return false;
    }

    if (password != confirmPassword) {
      errorMessage.value = 'Mật khẩu xác nhận chưa khớp.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _passwordResetService.resetPassword(
        ResetPasswordRequestModel(otp: otp, newPassword: password),
      );
      return true;
    } on PasswordResetException catch (error) {
      errorMessage.value = error.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Không thể đặt lại mật khẩu.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    otpTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.onClose();
  }
}
