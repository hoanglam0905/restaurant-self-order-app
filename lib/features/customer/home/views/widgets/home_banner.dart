import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 343 / 157,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/home/banner2.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.16),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 13,
              top: 38,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Up to 40% OFF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ON YOUR FIRST ORDER',
                    style: TextStyle(
                      color: Color(0xFFFFF6F6),
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'ORDER NOW',
                      style: TextStyle(
                        color: AppColors.offer,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 11,
              child: _BannerPagination(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerPagination extends StatelessWidget {
  const _BannerPagination();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: index == 0 ? 10 : 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: index == 0 ? 0.65 : 0.18),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
