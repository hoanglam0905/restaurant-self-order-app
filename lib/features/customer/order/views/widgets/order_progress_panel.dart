import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class OrderProgressPanel extends StatelessWidget {
  const OrderProgressPanel({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeIndex(status);
    final steps = const [
      _ProgressStep(label: 'Đã nhận', icon: Icons.check_rounded),
      _ProgressStep(label: 'Đang nấu', icon: Icons.soup_kitchen_rounded),
      _ProgressStep(label: 'Phục vụ', icon: Icons.room_service_rounded),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (var index = 0; index < steps.length; index++) ...[
            Expanded(
              child: _StepView(
                step: steps[index],
                active: index <= activeIndex,
              ),
            ),
            if (index < steps.length - 1)
              Container(
                width: 28,
                height: 2,
                color: index < activeIndex
                    ? AppColors.orderAccent
                    : const Color(0xFFE5E0E0),
              ),
          ],
        ],
      ),
    );
  }

  int _activeIndex(String status) {
    return switch (status) {
      'PREPARING' => 1,
      'READY' || 'SERVED' || 'COMPLETED' => 2,
      _ => 0,
    };
  }
}

class _ProgressStep {
  const _ProgressStep({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _StepView extends StatelessWidget {
  const _StepView({required this.step, required this.active});

  final _ProgressStep step;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active ? AppColors.orderAccent : const Color(0xFFF1EEEE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            step.icon,
            color: active ? Colors.white : AppColors.textSecondary,
            size: 18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? Colors.black : AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
