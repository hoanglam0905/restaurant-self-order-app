import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class MenuCategoryFilter extends StatelessWidget {
  const MenuCategoryFilter({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: Color(0xFFF7A43A),
              child: Icon(Icons.star_rounded, color: Colors.white, size: 15),
            ),
            SizedBox(width: 8),
            Text(
              'Select Category',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 28,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final category = categories[index];
              final selected = selectedCategory == category;
              return _CategoryChip(
                label: _categoryLabel(category),
                icon: _categoryIcon(category),
                selected: selected,
                onTap: () => onSelected(category),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemCount: categories.length,
          ),
        ),
      ],
    );
  }

  static String _categoryLabel(String category) {
    if (category == 'All') {
      return 'All';
    }
    return category.toUpperCase();
  }

  static IconData _categoryIcon(String category) {
    final value = category.toLowerCase();
    if (value.contains('veget')) {
      return Icons.eco_rounded;
    }
    if (value.contains('main') || value.contains('meat')) {
      return Icons.restaurant_rounded;
    }
    if (value.contains('dessert') || value.contains('cake')) {
      return Icons.cake_rounded;
    }
    return Icons.fastfood_rounded;
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.menuAccent : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? AppColors.menuAccent : const Color(0xFFE9E4E4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : Colors.black,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
