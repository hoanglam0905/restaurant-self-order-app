import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/forgot_password_request_model.dart';
import '../data/services/password_reset_service.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController({required PasswordResetService passwordResetService})
    : _passwordResetService = passwordResetService;

  final PasswordResetService _passwordResetService;

  final TextEditingController emailTextController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<String?> submit() async {
    final email = emailTextController.text.trim();
    if (email.isEmpty) {
      errorMessage.value = 'Vui lòng nhập email của bạn.';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _passwordResetService.requestOtp(
        ForgotPasswordRequestModel(email: email, username: email),
      );
      return email;
    } on PasswordResetException catch (error) {
      errorMessage.value = error.message;
      return null;
    } catch (_) {
      errorMessage.value = 'Không thể gửi mã xác nhận.';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailTextController.dispose();
    super.onClose();
  }
}
