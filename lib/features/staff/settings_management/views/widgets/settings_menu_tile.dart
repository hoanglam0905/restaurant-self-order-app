import 'package:flutter/material.dart';

class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({
    required this.iconCodePoint,
    required this.title,
    this.onTap,
    this.trailing,
    this.showChevron = true,
    this.showDivider = true,
    super.key,
  });

  final int iconCodePoint;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final icon = IconData(iconCodePoint, fontFamily: 'MaterialIcons');

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: const Color(0xFFBB5536), size: 18),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF272C37),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  trailing ?? const SizedBox.shrink(),
                  if (showChevron)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 21,
                        color: Color(0xFFB9C0CE),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F1F6)),
          ),
      ],
    );
  }
}
