import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_cta_button.dart';
import '../../../../../core/widgets/app_inline_text_link.dart';
import '../../../../../core/widgets/app_labeled_auth_text_field.dart';
import '../../../../staff/face_scan/views/staff_face_scan_view.dart';
import '../../../home/views/home_view.dart';
import '../../data/models/auth_response_model.dart';
import '../../password_reset/views/forgot_password_view.dart';
import '../../register/views/register_view.dart';
import '../controllers/login_controller.dart';
import '../data/services/login_service.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';
import 'widgets/login_social_section.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      LoginController(loginService: LoginService(apiClient: ApiClient())),
    );
  }

  @override
  void dispose() {
    Get.delete<LoginController>();
    super.dispose();
  }

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LoginHeader(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 24),
                    LoginForm(
                      controller: _controller,
                      onSubmit: () => _submit(context),
                      onForgotPassword: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordView(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    LoginSocialSection(
                      onGoogle: () => _showGoogleIdTokenDialog(context),
                      onFacebook: () => _showPendingAction(
                        context,
                        'Backend chua co API dang nhap Facebook.',
                      ),
                    ),
                    const SizedBox(height: 56),
                    _RegisterPrompt(
                      onRegister: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterView()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final auth = await _controller.submit();
    if (!context.mounted || auth == null) {
      return;
    }

    _navigateAfterAuth(context, auth);
  }

  Future<void> _showGoogleIdTokenDialog(BuildContext context) async {
    final idTokenController = TextEditingController();
    _controller.socialErrorMessage.value = '';

    final auth = await showDialog<AuthResponseModel>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            'Google staff login',
            style: TextStyle(
              color: Color(0xFF2D1D18),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Backend hien chi co API /auth/staff/google-login va can Google ID token.',
                style: TextStyle(
                  color: Color(0xFF5D5E61),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              AppLabeledAuthTextField(
                label: 'Google ID token',
                controller: idTokenController,
                hintText: 'eyJhbGciOi...',
                textInputAction: TextInputAction.done,
                onSubmitted: (_) =>
                    _submitGoogleIdToken(dialogContext, idTokenController.text),
              ),
              Obx(() {
                if (_controller.socialErrorMessage.value.isEmpty) {
                  return const SizedBox(height: 16);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(
                    _controller.socialErrorMessage.value,
                    style: const TextStyle(
                      color: Color(0xFFCC2B00),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Obx(
                () => AppCtaButton(
                  label: _controller.isSocialLoading.value
                      ? 'Dang dang nhap...'
                      : 'Dang nhap Google',
                  onPressed: () =>
                      _submitGoogleIdToken(dialogContext, idTokenController.text),
                  enabled: !_controller.isSocialLoading.value,
                  height: 48,
                  borderRadius: 8,
                  fontSize: 16,
                  backgroundColor: const Color(0xFFA73413),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: AppInlineTextLink(
                  label: 'Huy',
                  onTap: () => Navigator.pop(dialogContext),
                  textColor: const Color(0xFFA73413),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );

    idTokenController.dispose();
    if (!context.mounted || auth == null) {
      return;
    }

    _navigateAfterAuth(context, auth);
  }

  Future<void> _submitGoogleIdToken(
    BuildContext dialogContext,
    String idToken,
  ) async {
    final auth = await _controller.submitStaffGoogleIdToken(idToken);
    if (!dialogContext.mounted || auth == null) {
      return;
    }

    Navigator.pop(dialogContext, auth);
  }

  void _navigateAfterAuth(BuildContext context, AuthResponseModel auth) {
    final destination = _destinationFor(auth);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (_) => false,
    );
  }

  Widget _destinationFor(AuthResponseModel auth) {
    final userType = auth.userType.toUpperCase();
    if (userType == 'STAFF' || userType == 'ADMIN') {
      return const StaffFaceScanView();
    }
    return const HomeView();
  }

  void _showPendingAction(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.welcomeAccent,
      ),
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({required this.onRegister});

  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        const Text(
          'Chua co tai khoan?',
          style: TextStyle(color: Color(0xFF5D5E61), fontSize: 16, height: 1.5),
        ),
        AppInlineTextLink(
          label: 'Dang ky',
          onTap: onRegister,
          textColor: const Color(0xFFA73413),
          fontSize: 16,
        ),
      ],
    );
  }
}
