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

  Future<AuthResponseModel?>? _pendingRegistration;
  String? _pendingRegistrationError;

  final RxBool isLoading = false.obs;
  final RxBool isVerifyingOtp = false.obs;
  final RxBool isResendingOtp = false.obs;
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
    otpTextController.text = '123456';
    otpErrorMessage.value = '';
  }

  bool startRegistration() {
    final fullName = fullNameTextController.text.trim();
    final email = emailTextController.text.trim();
    final phone = phoneTextController.text.trim();
    final password = passwordTextController.text;
    final confirmPassword = confirmPasswordTextController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Vui long nhap ho ten, email va mat khau.';
      return false;
    }

    if (password.length < 8) {
      errorMessage.value = 'Mat khau phai co it nhat 8 ky tu.';
      return false;
    }

    if (password != confirmPassword) {
      errorMessage.value = 'Mat khau xac nhan chua khop.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    _pendingRegistrationError = null;

    _pendingRegistration = _registerService
        .register(
          RegisterRequestModel(
            username: email,
            email: email,
            password: password,
            phone: phone.isEmpty ? null : phone,
            fullName: fullName,
          ),
        )
        .then<AuthResponseModel?>((auth) => auth)
        .catchError((Object error) {
          _pendingRegistrationError = error is RegisterException
              ? error.message
              : 'Khong the dang ky.';
          return null;
        })
        .whenComplete(() {
          isLoading.value = false;
        });

    return true;
  }

  Future<AuthResponseModel?> verifyRegisterOtp() async {
    final email = emailTextController.text.trim();
    final otp = otpTextController.text.trim();

    if (otp.isEmpty) {
      otpErrorMessage.value = 'Vui long nhap ma OTP.';
      return null;
    }

    isVerifyingOtp.value = true;
    otpErrorMessage.value = '';

    try {
      final registration = await _pendingRegistration;
      if (registration == null) {
        otpErrorMessage.value =
            _pendingRegistrationError ?? 'Khong the tao tai khoan.';
        return null;
      }

      return await _registerService.verifyRegisterOtp(
        VerifyRegisterOtpRequestModel(email: email, otp: otp),
      );
    } on RegisterException catch (error) {
      otpErrorMessage.value = error.message;
      return null;
    } catch (_) {
      otpErrorMessage.value = 'Khong the xac thuc OTP.';
      return null;
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  Future<bool> resendRegisterOtp() async {
    final email = emailTextController.text.trim();
    if (email.isEmpty) {
      otpErrorMessage.value = 'Email dang ky khong hop le.';
      return false;
    }

    isResendingOtp.value = true;
    otpErrorMessage.value = '';

    try {
      await _registerService.resendRegisterOtp(email);
      return true;
    } on RegisterException catch (error) {
      otpErrorMessage.value = error.message;
      return false;
    } catch (_) {
      otpErrorMessage.value = 'Khong the gui lai OTP.';
      return false;
    } finally {
      isResendingOtp.value = false;
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
