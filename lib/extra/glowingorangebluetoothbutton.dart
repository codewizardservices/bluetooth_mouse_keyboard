import 'package:bluetoothairmousekeyboard/theme/theme.dart';
import 'package:flutter/material.dart';

// import your theme file
// import 'app_theme_colors.dart';

class GlowingOrangeButton extends StatefulWidget {
  const GlowingOrangeButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.iconData,
    this.icon,
    this.orange = AppThemeColors.accentCyan, // use theme color
  }) : assert(
          iconData != null || icon != null,
          'Provide either iconData or icon',
        );

  final VoidCallback onPressed;
  final String text;

  final IconData? iconData;
  final Widget? icon;

  final Color orange;

  @override
  State<GlowingOrangeButton> createState() => _GlowingOrangeButtonState();
}

class _GlowingOrangeButtonState extends State<GlowingOrangeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconWidget =
        widget.icon ?? Icon(widget.iconData!, color: Colors.white, size: 25);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final glowOpacity = lerpDouble(0.2, 0.7, _c.value)!;
        final blur = lerpDouble(12, 28, _c.value)!;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: widget.orange.withOpacity(glowOpacity),
                blurRadius: blur,
                spreadRadius: 1.2,
              ),
            ],
          ),
          child: FilledButton.icon(
            onPressed: widget.onPressed,
            icon: iconWidget,
            label: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppThemeColors.accentCyan,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(
                  color: AppThemeColors.stroke, // subtle outline
                ),
              ),
              elevation: 0,
            ),
          ),
        );
      },
    );
  }
}

// helper
double? lerpDouble(num? a, num? b, double t) {
  a ??= 0.0;
  b ??= 0.0;
  return a * (1.0 - t) + b * t;
}