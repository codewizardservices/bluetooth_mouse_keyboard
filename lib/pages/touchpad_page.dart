import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class TouchpadPage extends StatefulWidget {
  const TouchpadPage({super.key});

  @override
  State<TouchpadPage> createState() => _TouchpadPageState();
}

class _TouchpadPageState extends State<TouchpadPage>
    with SingleTickerProviderStateMixin {
  // Smoothed cursor + raw target cursor
  Offset _cursor = const Offset(0.5, 0.5); // displayed (smoothed)
  Offset _targetCursor = const Offset(0.5, 0.5); // where finger wants it

  double _sensitivity = 1.0;
  int _clicks = 0;

  late final Ticker _ticker;

  // Used to drive effects
  double _speed = 0.0; // smoothed speed (0..small)
  Offset _prevCursor = const Offset(0.5, 0.5);

  // Optional trail (last positions)
  final List<Offset> _trail = [];
  static const int _trailMax = 8;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((_) {
      // Low-pass filter smoothing.
      // Increase follow for snappier (0.22), decrease for smoother (0.12)
      const follow = 0.12;

      final before = _cursor;
      _cursor = Offset(
        before.dx + (_targetCursor.dx - before.dx) * follow,
        before.dy + (_targetCursor.dy - before.dy) * follow,
      );

      // speed estimate (distance per tick)
      final frameSpeed = (_cursor - _prevCursor).distance;
      _prevCursor = _cursor;

      // smooth the speed value (keeps effect stable)
      _speed = _speed * 0.85 + frameSpeed * 0.15;

      // update trail
      _trail.insert(0, _cursor);
      if (_trail.length > _trailMax) _trail.removeLast();

      setState(() {});
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _move(Offset delta) {
    final dx = delta.dx / 900.0 * _sensitivity;
    final dy = delta.dy / 900.0 * _sensitivity;

    // Update TARGET only (do not setState here)
    _targetCursor = Offset(
      (_targetCursor.dx + dx).clamp(0.0, 1.0),
      (_targetCursor.dy + dy).clamp(0.0, 1.0),
    );
  }

  Future<void> _haptic() async {
    await HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Map speed to nice effect ranges
    final glowBoost = (_speed * 10).clamp(0.0, 0.35);
    final blur = 18 + (_speed * 260).clamp(0.0, 50.0);
    final spread = 2 + (_speed * 90).clamp(0.0, 10.0);
    final scale = 1.0 + (_speed * 16).clamp(0.0, 0.40);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            cs.surface.withOpacity(0.85),
            const Color(0xFF06131A),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _Pill(
                  icon: Icons.wifi_tethering,
                  label: 'Connected',
                  tone: cs.primary,
                ),
                const SizedBox(width: 10),
                _Pill(
                  icon: Icons.speed_rounded,
                  label: 'Sensitivity',
                  tone: cs.secondary,
                ),
                const Spacer(),
                _Pill(
                  icon: Icons.ads_click,
                  label: '$_clicks',
                  tone: cs.tertiary,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: cs.surfaceContainerHighest.withOpacity(0.7),
                    border: Border.all(
                      color: cs.primary.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanUpdate: (d) => _move(d.delta),
                          onDoubleTap: () async {
                            await _haptic();
                            setState(() => _clicks++);
                          },
                          onTap: () async {
                            await _haptic();
                            setState(() => _clicks++);
                          },
                          child: const SizedBox.expand(),
                        ),
                      ),

                      // ✨ Trail Effect
                      for (int i = 0; i < _trail.length; i++)
                        Align(
                          alignment: Alignment(
                            _trail[i].dx * 2 - 1,
                            _trail[i].dy * 2 - 1,
                          ),
                          child: Opacity(
                            opacity: (0.18 - i * 0.02).clamp(0.0, 0.18),
                            child: Container(
                              width: 16 - i.toDouble(),
                              height: 16 - i.toDouble(),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.primary.withOpacity(0.20),
                              ),
                            ),
                          ),
                        ),

                      // ✅ Smooth Cursor + Glow + Scale
                      Align(
                        alignment: Alignment(
                          _cursor.dx * 2 - 1,
                          _cursor.dy * 2 - 1,
                        ),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: blur,
                                  spreadRadius: spread,
                                  color: cs.primary.withOpacity(
                                    0.25 + glowBoost,
                                  ),
                                ),
                              ],
                              gradient: RadialGradient(
                                colors: [
                                  cs.primary,
                                  cs.primary.withOpacity(0.12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 15,
                        right: 15,
                        top: 10,
                        child: Opacity(
                          opacity: 0.65,
                          child: Column(
                            children: [
                              Icon(
                                Icons.gesture,
                                size: 15,
                                color: cs.onSurface,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'How to Use?\nDrag to move • Tap to click • Double-tap = double click',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: cs.onSurface),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.mouse,
                        label: 'Left Click',
                        onPressed: () async {
                          await _haptic();
                          setState(() => _clicks++);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.more_horiz,
                        label: 'Right Click',
                        onPressed: () async {
                          await _haptic();
                          setState(() => _clicks++);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cs.primary.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tune_rounded, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Slider(
                            value: _sensitivity,
                            min: 0.5,
                            max: 2.5,
                            divisions: 20,
                            label: _sensitivity.toStringAsFixed(2),
                            onChanged: (v) => setState(() => _sensitivity = v),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Text(
                            _sensitivity.toStringAsFixed(2),
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.tone});

  final IconData icon;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surfaceContainerHigh.withOpacity(0.55),
        border: Border.all(color: tone.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tone),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: cs.surfaceContainerHighest.withOpacity(0.75),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
