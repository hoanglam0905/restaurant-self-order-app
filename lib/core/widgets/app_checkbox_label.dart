import 'package:flutter/material.dart';

class AppCheckboxLabel extends StatelessWidget {
  const AppCheckboxLabel({
    required this.value,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: (nextValue) => onChanged(nextValue ?? false),
              side: const BorderSide(color: Color(0xFFE0BFB7)),
              activeColor: const Color(0xFFA73413),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5D5E61),
              fontSize: 14,
              height: 1.42,
            ),
          ),
        ],
      ),
    );
  }
}
