import 'package:flutter/material.dart';

class AppQuantityStepper extends StatelessWidget {
  const AppQuantityStepper({
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
    super.key,
  });

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 56.0 : 96.0;
    final height = compact ? 24.0 : 40.0;
    final valueWidth = compact ? 28.0 : 46.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0F2),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          SizedBox(
            width: valueWidth,
            child: Center(
              child: Text(
                value.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: compact ? 11 : 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _StepperTapArea(
                    icon: Icons.keyboard_arrow_up_rounded,
                    onTap: onIncrement,
                    compact: compact,
                  ),
                ),
                Expanded(
                  child: _StepperTapArea(
                    icon: Icons.keyboard_arrow_down_rounded,
                    onTap: onDecrement,
                    compact: compact,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperTapArea extends StatelessWidget {
  const _StepperTapArea({
    required this.icon,
    required this.onTap,
    required this.compact,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Icon(icon, color: Colors.white, size: compact ? 16 : 22),
      ),
    );
  }
}
