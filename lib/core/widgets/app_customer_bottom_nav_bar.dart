import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCustomerBottomNavBar extends StatelessWidget {
  const AppCustomerBottomNavBar({
    required this.currentIndex,
    required this.onItemSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  static const List<_CustomerNavItem> _items = [
    _CustomerNavItem(icon: Icons.home_outlined, label: 'Home'),
    _CustomerNavItem(icon: Icons.event_note_rounded, label: 'Bookings'),
    _CustomerNavItem(icon: Icons.menu_book_rounded, label: 'Menu'),
    _CustomerNavItem(icon: Icons.history_rounded, label: 'History'),
    _CustomerNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F4F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0E3E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = currentIndex == index;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onItemSelected(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: selected
                          ? AppColors.welcomeAccent
                          : const Color(0xFF9A9699),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? AppColors.welcomeAccent
                            : const Color(0xFF9A9699),
                        fontSize: 10,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _CustomerNavItem {
  const _CustomerNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
