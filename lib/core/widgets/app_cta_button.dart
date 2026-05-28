import 'package:flutter/material.dart';

class AppCtaButton extends StatelessWidget {
  const AppCtaButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.gradient,
    this.height = 58,
    this.borderRadius = 16,
    this.fontSize = 18,
    this.boxShadow,
    this.enabled = true,
    this.trailing,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Gradient? gradient;
  final double height;
  final double borderRadius;
  final double fontSize;
  final List<BoxShadow>? boxShadow;
  final bool enabled;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: enabled ? onPressed : null,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: gradient == null ? backgroundColor : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: boxShadow,
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.72,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        height: 1.55,
                      ),
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
