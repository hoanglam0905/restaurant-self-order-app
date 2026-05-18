import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_action_tile.dart';
import '../../controllers/home_controller.dart';

class HomeDeliveryPanel extends StatelessWidget {
  const HomeDeliveryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: _GreetingCopy()),
        const SizedBox(width: 8),
        AppActionTile(
          imagePath: 'assets/images/home/call_staff.png',
          label: 'Call Staff',
          onTap: () => _showPendingFeature(context),
        ),
        const SizedBox(width: 8),
        AppActionTile(
          imagePath: 'assets/images/home/call_payment.png',
          label: 'Call Payment',
          onTap: () => _showPendingFeature(context),
        ),
      ],
    );
  }

  void _showPendingFeature(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This action needs a table/order contract.'),
      ),
    );
  }
}

class _GreetingCopy extends StatelessWidget {
  const _GreetingCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.4,
            ),
            children: [
              TextSpan(text: 'Good Morning '),
              TextSpan(
                text: '${HomeController.customerName}!',
                style: TextStyle(color: AppColors.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 7,
          runSpacing: 4,
          children: [
            const Text(
              'We will deliver your food to\nyour table:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            Container(
              height: 18,
              constraints: const BoxConstraints(minWidth: 31),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text(
                HomeController.tableCode,
                style: TextStyle(fontSize: 11, height: 1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
