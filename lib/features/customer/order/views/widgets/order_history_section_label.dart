import 'package:flutter/material.dart';

class OrderHistorySectionLabel extends StatelessWidget {
  const OrderHistorySectionLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE9E1E2), height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8D888C),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE9E1E2), height: 1)),
      ],
    );
  }
}
