import 'package:flutter/material.dart';

class AppLabeledDivider extends StatelessWidget {
  const AppLabeledDivider({
    required this.label,
    this.lineColor = const Color(0x33FFFFFF),
    this.labelColor = const Color(0x66FFFFFF),
    super.key,
  });

  final String label;
  final Color lineColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
              height: 1.5,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: lineColor)),
      ],
    );
  }
}
