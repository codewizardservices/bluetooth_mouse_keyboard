import 'package:flutter/material.dart';

import '../control/mini_keycap_data.dart';

class MiniKeycap extends StatefulWidget {
  const MiniKeycap({
    super.key,
    required this.keyData,
    required this.onPressed,
    this.isActive = false,
  });

  final MiniKeycapData keyData;
  final VoidCallback onPressed;

  /// When true, the key renders as "latched" (useful for Fn/Shift toggles).
  final bool isActive;

  @override
  State<MiniKeycap> createState() => _MiniKeycapState();
}

class _MiniKeycapState extends State<MiniKeycap> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final k = widget.keyData;

    // Match the reference photo: cyan secondary legends.
    const accent = Color(0xFF33D3FF);

    final border = Border.all(
      color: (widget.isActive ? accent : const Color(0xFF2B2F33)).withOpacity(
        widget.isActive ? 0.85 : 0.9,
      ),
      width: widget.isActive ? 1.3 : 1,
    );

    final bg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: widget.isActive
          ? [const Color(0xFF2C3136), const Color(0xFF14181B)]
          : [const Color(0xFF262A2E), const Color(0xFF111316)],
    );

    final shape = switch (k.style) {
      KeycapStyle.round => const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      KeycapStyle.pill => const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      KeycapStyle.longPill => const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    };

    return AnimatedScale(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      scale: _down ? 0.97 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: shape.borderRadius as BorderRadius,
          onHighlightChanged: (v) => setState(() => _down = v),
          onTap: widget.onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: bg,
              border: border,
              borderRadius: (shape.borderRadius as BorderRadius),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                  color: Colors.black.withOpacity(_down ? 0.10 : 0.30),
                ),
                if (widget.isActive)
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 0),
                    color: accent.withOpacity(0.18),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: (shape.borderRadius as BorderRadius),
              child: Stack(
                children: [
                  // Subtle "dish" highlight like the photo.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.2, -0.6),
                          radius: 1.15,
                          colors: [
                            Colors.white.withOpacity(0.10),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            k.primary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.1,
                                  height: 1.0,
                                  color: Colors.white.withOpacity(0.92),
                                ),
                          ),
                        ),
                        if ((k.secondary ?? '').isNotEmpty)
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              k.secondary!,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.1,
                                    color: accent,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
