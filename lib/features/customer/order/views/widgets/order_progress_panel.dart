import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class OrderProgressPanel extends StatelessWidget {
  const OrderProgressPanel({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeIndex(status);
    final steps = const [
      _ProgressStep(label: 'Đã xác nhận', icon: Icons.check_rounded),
      _ProgressStep(label: 'Đang chuẩn bị', icon: Icons.soup_kitchen_rounded),
      _ProgressStep(label: 'Đang giao', icon: Icons.room_service_rounded),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x1FE0BFB7)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRẠNG THÁI ĐƠN HÀNG',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Đang chuẩn bị',
                      style: TextStyle(
                        color: AppColors.orderAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Dự kiến',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '15-20 phút',
                    style: TextStyle(
                      color: Color(0xFF161C23),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
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
        ],
      ),
    );
  }

  int _activeIndex(String status) {
    return switch (status.toUpperCase()) {
      'PROCESSING' => 1,
      'COMPLETED' => 2,
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
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: active ? AppColors.orderAccent : const Color(0xFFF1EEEE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            step.icon,
            color: active ? Colors.white : AppColors.textSecondary,
            size: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? Colors.black : AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
