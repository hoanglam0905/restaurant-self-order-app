import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/auth_response_model.dart';
import '../data/models/google_login_request_model.dart';
import '../data/models/login_request_model.dart';
import '../data/services/login_service.dart';

class LoginController extends GetxController {
  LoginController({required LoginService loginService})
    : _loginService = loginService;

  final LoginService _loginService;

  final TextEditingController loginTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isSocialLoading = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString socialErrorMessage = ''.obs;

  void toggleRememberMe(bool value) {
    rememberMe.value = value;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<AuthResponseModel?> submit() async {
    final login = loginTextController.text.trim();
    final password = passwordTextController.text;

    if (login.isEmpty || password.isEmpty) {
      errorMessage.value = 'Vui lòng nhập email và mật khẩu.';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      return await _loginService.login(
        LoginRequestModel(login: login, password: password),
      );
    } on LoginException catch (error) {
      errorMessage.value = error.message;
      return null;
    } catch (_) {
      errorMessage.value = 'Không thể đăng nhập.';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<AuthResponseModel?> submitStaffGoogleIdToken(String idToken) async {
    final trimmedIdToken = idToken.trim();
    if (trimmedIdToken.isEmpty) {
      socialErrorMessage.value = 'Vui long nhap Google ID token.';
      return null;
    }

    isSocialLoading.value = true;
    socialErrorMessage.value = '';

    try {
      return await _loginService.staffGoogleLogin(
        GoogleLoginRequestModel(idToken: trimmedIdToken),
      );
    } on LoginException catch (error) {
      socialErrorMessage.value = error.message;
      return null;
    } catch (_) {
      socialErrorMessage.value = 'Khong the dang nhap bang Google.';
      return null;
    } finally {
      isSocialLoading.value = false;
    }
  }

  @override
  void onClose() {
    loginTextController.dispose();
    passwordTextController.dispose();
    super.onClose();
  }
}
