import 'package:flutter/material.dart';

import '../../../../core/storage/table_session_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../auth/login/views/login_view.dart';
import '../../auth/register/views/register_view.dart';
import '../../home/data/models/table_qr_payload.dart';
import '../../home/views/table_qr_scan_view.dart';
import '../../menu/views/menu_view.dart';
import 'widgets/welcome_action_section.dart';
import 'widgets/welcome_brand_header.dart';
import 'widgets/welcome_footer.dart';
import 'widgets/welcome_hero_content.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome/welcome_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x80000000),
                  Color(0xA6000000),
                  Color(0xD9000000),
                ],
                stops: [0, 0.48, 1],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final brandToHeroGap = (constraints.maxHeight * 0.16)
                    .clamp(70.0, 130.0)
                    .toDouble();
                final footerGap = (constraints.maxHeight * 0.07)
                    .clamp(36.0, 64.0)
                    .toDouble();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        const WelcomeBrandHeader(),
                        SizedBox(height: brandToHeroGap),
                        const WelcomeHeroContent(),
                        const SizedBox(height: 42),
                        WelcomeActionSection(
                          onQrScan: () => _openOrderMenu(context),
                          onRegister: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterView(),
                            ),
                          ),
                          onGoogle: () => _showPendingAction(
                            context,
                            'Google sign-in needs an idToken flow.',
                          ),
                          onFacebook: () => _showPendingAction(
                            context,
                            'Facebook sign-in has no backend contract yet.',
                          ),
                        ),
                        WelcomeFooter(
                          onLogin: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginView(),
                            ),
                          ),
                        ),
                        SizedBox(height: footerGap),
                        const SizedBox(height: 14),
                        const _HomeIndicator(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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

  Future<void> _openOrderMenu(BuildContext context) async {
    final payload = await Navigator.push<TableQrPayload>(
      context,
      MaterialPageRoute(builder: (_) => const TableQrScanView()),
    );

    if (!context.mounted || payload == null) {
      return;
    }

    await TableSessionStorage().saveTableSession(
      tableId: payload.tableId,
      tableLabel: payload.tableLabel,
    );

    if (!context.mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenuView.order(
          tableId: payload.tableId,
          tableLabel: payload.tableLabel,
        ),
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
