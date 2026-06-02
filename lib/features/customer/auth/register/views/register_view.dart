import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_cta_button.dart';
import '../../../../../core/widgets/app_inline_text_link.dart';
import '../../../../../core/widgets/app_labeled_auth_text_field.dart';
import '../../../home/views/home_view.dart';
import '../../data/models/auth_response_model.dart';
import '../../login/views/login_view.dart';
import '../controllers/register_controller.dart';
import '../data/services/register_service.dart';
import 'widgets/register_card.dart';
import 'widgets/register_footer.dart';
import 'widgets/register_header.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      RegisterController(
        registerService: RegisterService(apiClient: ApiClient()),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<RegisterController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                children: [
                  const RegisterHeader(),
                  const SizedBox(height: 40),
                  RegisterCard(
                    controller: _controller,
                    onSubmit: () => _submit(context),
                    onGoogle: () => _showPendingAction(
                      context,
                      'Backend chua co API dang ky Google cho customer.',
                    ),
                    onFacebook: () => _showPendingAction(
                      context,
                      'Backend chua co API dang ky Facebook.',
                    ),
                    onLogin: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                    ),
                  ),
                  const SizedBox(height: 70),
                  const RegisterFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final canContinue = _controller.startRegistration();
    if (!context.mounted || !canContinue) {
      return;
    }

    final auth = await _showOtpDialog(context);
    if (!context.mounted || auth == null) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeView()),
      (_) => false,
    );
  }

  Future<AuthResponseModel?> _showOtpDialog(BuildContext context) {
    _controller.resetOtpState();

    return showDialog<AuthResponseModel>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            'Xac thuc email',
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
              Text(
                'Nhap ma OTP da gui toi ${_controller.emailTextController.text.trim()}.',
                style: const TextStyle(
                  color: Color(0xFF5D5E61),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              AppLabeledAuthTextField(
                label: 'OTP',
                controller: _controller.otpTextController,
                hintText: '123456',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _verifyOtp(dialogContext),
              ),
              Obx(() {
                if (_controller.otpErrorMessage.value.isEmpty) {
                  return const SizedBox(height: 16);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(
                    _controller.otpErrorMessage.value,
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
                  label: _controller.isVerifyingOtp.value
                      ? 'Dang xac thuc...'
                      : 'Xac thuc OTP',
                  onPressed: () => _verifyOtp(dialogContext),
                  enabled: !_controller.isVerifyingOtp.value,
                  height: 48,
                  borderRadius: 8,
                  fontSize: 16,
                  backgroundColor: const Color(0xFFA73413),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => AppInlineTextLink(
                      label: _controller.isResendingOtp.value
                          ? 'Dang gui lai...'
                          : 'Gui lai OTP',
                      onTap: _controller.isResendingOtp.value
                          ? () {}
                          : () => _resendOtp(dialogContext),
                      textColor: const Color(0xFFA73413),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  AppInlineTextLink(
                    label: 'Huy',
                    onTap: () => Navigator.pop(dialogContext),
                    textColor: const Color(0xFFA73413),
                    fontSize: 14,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _verifyOtp(BuildContext dialogContext) async {
    final auth = await _controller.verifyRegisterOtp();
    if (!dialogContext.mounted || auth == null) {
      return;
    }

    Navigator.pop(dialogContext, auth);
  }

  Future<void> _resendOtp(BuildContext dialogContext) async {
    final sent = await _controller.resendRegisterOtp();
    if (!dialogContext.mounted || !sent) {
      return;
    }

    ScaffoldMessenger.of(dialogContext).showSnackBar(
      const SnackBar(content: Text('Da gui lai OTP.')),
    );
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
