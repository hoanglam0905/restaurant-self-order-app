import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class MenuTopBar extends StatelessWidget {
  const MenuTopBar({
    required this.title,
    required this.onBack,
    this.cartCount = 0,
    this.tableLabel,
    this.onCartTap,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final int cartCount;
  final String? tableLabel;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: onBack,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202020),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (tableLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Bàn $tableLabel',
                  style: const TextStyle(
                    color: AppColors.orderAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          if (onCartTap != null)
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: onCartTap,
                  child: SizedBox(
                    width: 52,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFF303030),
                          size: 26,
                        ),
                        if (cartCount > 0)
                          Positioned(
                            top: 8,
                            right: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
