import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Pressable extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final BorderRadius borderRadius;
  // final bool haptic;
  VoidCallback? onLongPress;
  VoidCallback? onLongRelease;

  Pressable({
    super.key,
    required this.onTap,
    required this.child,
    required this.borderRadius,
    // this.haptic = true,
    this.onLongPress,
    this.onLongRelease,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _setDown(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
  }

  bool isHapticEnabled = true;
  void getVibrationState() async {
    // todo
  // final enabled = await ToggleSettings.get(ToggleSetting.haptic);
  final enabled = true;
  if (!mounted) return;
  setState(() => isHapticEnabled = enabled);
}


  @override
  void initState() {
    getVibrationState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _down ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          splashColor: const Color(0x22FF5A1F),
          highlightColor: const Color(0x11FFFFFF),
          onHighlightChanged: _setDown,
          onTap: () {
            if (isHapticEnabled) HapticFeedback.lightImpact();
            widget.onTap();
          },
          onLongPress: () {
            if (isHapticEnabled) HapticFeedback.lightImpact();
            widget.onLongPress?.call();
          },
          onLongPressUp: () {
            if (isHapticEnabled) HapticFeedback.lightImpact();
            widget.onLongRelease?.call();
          },
          child: widget.child,
        ),
      ),
    );
  }
}
