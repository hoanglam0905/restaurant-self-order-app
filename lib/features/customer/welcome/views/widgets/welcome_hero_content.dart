import 'package:flutter/material.dart';

class WelcomeHeroContent extends StatelessWidget {
  const WelcomeHeroContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Thưởng thức hương vị\nấm áp từ trái tim.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Trải nghiệm ẩm thực tinh tế trong không gian\nsang trọng và gần gũi nhất.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.70),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            height: 1.62,
          ),
        ),
      ],
    );
  }
}
