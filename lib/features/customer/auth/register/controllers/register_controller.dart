import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/auth_response_model.dart';
import '../data/models/register_request_model.dart';
import '../data/models/verify_register_otp_request_model.dart';
import '../data/services/register_service.dart';

class RegisterController extends GetxController {
  RegisterController({required RegisterService registerService})
    : _registerService = registerService;

  final RegisterService _registerService;

  final TextEditingController fullNameTextController = TextEditingController();
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController phoneTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController confirmPasswordTextController =
      TextEditingController();
  final TextEditingController otpTextController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isVerifyingOtp = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString otpErrorMessage = ''.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void resetOtpState() {
    otpTextController.clear();
    otpErrorMessage.value = '';
  }

  Future<AuthResponseModel?> submit() async {
    final fullname = fullNameTextController.text.trim();
    final email = emailTextController.text.trim();
    final phone = phoneTextController.text.trim();
    final password = passwordTextController.text;
    final confirmPassword = confirmPasswordTextController.text;

    if (fullname.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Vui lòng nhập họ tên, email và mật khẩu.';
      return null;
    }

    if (password.length < 8) {
      errorMessage.value = 'Mật khẩu phải có ít nhất 8 ký tự.';
      return null;
    }

    if (password != confirmPassword) {
      errorMessage.value = 'Mật khẩu xác nhận chưa khớp.';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      return await _registerService.register(
        RegisterRequestModel(
          username: email,
          email: email,
          password: password,
          phone: phone.isEmpty ? null : phone,
          fullname: fullname,
        ),
      );
    } on RegisterException catch (error) {
      errorMessage.value = error.message;
      return null;
    } catch (_) {
      errorMessage.value = 'Không thể đăng ký.';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<AuthResponseModel?> verifyRegisterOtp() async {
    final email = emailTextController.text.trim();
    final otp = otpTextController.text.trim();

    if (otp.isEmpty) {
      otpErrorMessage.value = 'Vui lòng nhập mã OTP.';
      return null;
    }

    isVerifyingOtp.value = true;
    otpErrorMessage.value = '';

    try {
      return await _registerService.verifyRegisterOtp(
        VerifyRegisterOtpRequestModel(email: email, otp: otp),
      );
    } on RegisterException catch (error) {
      otpErrorMessage.value = error.message;
      return null;
    } catch (_) {
      otpErrorMessage.value = 'Không thể xác thực OTP.';
      return null;
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  @override
  void onClose() {
    fullNameTextController.dispose();
    emailTextController.dispose();
    phoneTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    otpTextController.dispose();
    super.onClose();
  }
}
