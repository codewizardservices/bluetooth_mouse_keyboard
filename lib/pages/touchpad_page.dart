import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class TouchpadPage extends StatefulWidget {
   TouchpadPage({
    super.key,
    required this.sendReport,
    required this.onLeftClick,
    required this.onRightClick,
    required this.onScroll,
    this.onTwoFingerActive,
    this.onBack
  });

  VoidCallback? onBack;
  final void Function(List<int> report) sendReport;

  /// Tap = left click
  final FutureOr<void> Function() onLeftClick;

  /// Right click callback (we'll trigger it on 2-finger tap)
  final FutureOr<void> Function() onRightClick;

  /// Two-finger scroll output (wheel steps, can be +/-)
  final FutureOr<void> Function(int wheelSteps) onScroll;

  /// Optional: tells you when two-finger mode starts/stops
  final void Function(bool active)? onTwoFingerActive;

  @override
  State<TouchpadPage> createState() => _TouchpadPageState();
}

class _TouchpadPageState extends State<TouchpadPage>
    with SingleTickerProviderStateMixin {
  Offset _cursor = const Offset(0.5, 0.5);
  Offset _targetCursor = const Offset(0.5, 0.5);

  double _sensitivity = 1.0;
  int _clicks = 0;

  late final Ticker _ticker;

  double _speed = 0.0;
  Offset _prevCursor = const Offset(0.5, 0.5);

  final List<Offset> _trail = [];
  static const int _trailMax = 8;

  // ---- multi-touch for 2-finger scroll / 2-finger tap ----
  final Map<int, Offset> _pointers = {};
  Offset? _lastTwoFingerCentroid;
  double _scrollCarry = 0.0;
  bool _twoFingerMode = false;

  // Two-finger tap detection
  bool _twoFingerTapCandidate = false;
  Offset? _twoFingerTapStartCentroid;
  int _twoFingerTapMaxPointers = 0;
  Timer? _twoFingerTapTimer;

  static const Duration _twoFingerTapTimeout = Duration(milliseconds: 180);
  static const double _twoFingerTapMoveThresholdPx = 10.0;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((_) {
      const follow = 0.12;

      final before = _cursor;
      _cursor = Offset(
        before.dx + (_targetCursor.dx - before.dx) * follow,
        before.dy + (_targetCursor.dy - before.dy) * follow,
      );

      final frameSpeed = (_cursor - _prevCursor).distance;
      _prevCursor = _cursor;
      _speed = _speed * 0.85 + frameSpeed * 0.15;

      _trail.insert(0, _cursor);
      if (_trail.length > _trailMax) _trail.removeLast();

      setState(() {});
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _twoFingerTapTimer?.cancel();
    super.dispose();
  }

  Future<void> _haptic() async => HapticFeedback.selectionClick();

  // ---------- HID report helpers (movement stays here) ----------
  List<int> _buildMouseReport({
    required int buttons,
    required int x,
    required int y,
    required int wheel,
  }) {
    int clamp127(int v) => max(-127, min(127, v));
    return [
      buttons & 0xFF,
      clamp127(x) & 0xFF,
      clamp127(y) & 0xFF,
      clamp127(wheel) & 0xFF,
    ];
  }

  void _sendMove(double dx, double dy) {
    final scale = 6.0 * _sensitivity;

    widget.sendReport(_buildMouseReport(
      buttons: 0x00,
      x: (dx * scale).round(),
      y: (dy * scale).round(),
      wheel: 0,
    ));
  }

  Future<void> _doLeftClick() async {
    await _haptic();
    await widget.onLeftClick();
    if (mounted) setState(() => _clicks++);
  }

  Future<void> _doRightClick() async {
    await _haptic();
    await widget.onRightClick();
    if (mounted) setState(() => _clicks++);
  }

  // ---------- UI cursor movement ----------
  void _moveCursor(Offset delta) {
    final dx = delta.dx / 900.0 * _sensitivity;
    final dy = delta.dy / 900.0 * _sensitivity;

    _targetCursor = Offset(
      (_targetCursor.dx + dx).clamp(0.0, 1.0),
      (_targetCursor.dy + dy).clamp(0.0, 1.0),
    );

    _sendMove(delta.dx, delta.dy);
  }

  // ---------- Two-finger helpers ----------
  Offset _centroidOfTwo() {
    final vals = _pointers.values.toList(growable: false);
    return Offset(
      (vals[0].dx + vals[1].dx) / 2.0,
      (vals[0].dy + vals[1].dy) / 2.0,
    );
  }

  void _setTwoFingerMode(bool v) {
    if (_twoFingerMode == v) return;
    _twoFingerMode = v;
    widget.onTwoFingerActive?.call(v);
  }

  void _startTwoFingerTapCandidate() {
    _twoFingerTapCandidate = true;
    _twoFingerTapMaxPointers = max(_twoFingerTapMaxPointers, _pointers.length);
    _twoFingerTapStartCentroid = _centroidOfTwo();

    _twoFingerTapTimer?.cancel();
    _twoFingerTapTimer = Timer(_twoFingerTapTimeout, () {
      // timed out => not a tap
      _twoFingerTapCandidate = false;
    });
  }

  void _cancelTwoFingerTapCandidate() {
    _twoFingerTapCandidate = false;
    _twoFingerTapStartCentroid = null;
    _twoFingerTapMaxPointers = 0;
    _twoFingerTapTimer?.cancel();
    _twoFingerTapTimer = null;
  }

  Future<void> _maybeFireTwoFingerTap() async {
    // Must have started as 2-finger, stayed within time, minimal movement
    if (!_twoFingerTapCandidate) return;
    if (_twoFingerTapMaxPointers < 2) return;

    final start = _twoFingerTapStartCentroid;
    if (start != null && _lastTwoFingerCentroid != null) {
      final moved = (_lastTwoFingerCentroid! - start).distance;
      if (moved > _twoFingerTapMoveThresholdPx) {
        _cancelTwoFingerTapCandidate();
        return;
      }
    }

    _cancelTwoFingerTapCandidate();
    await _doRightClick(); // ✅ two-finger click => right click
  }

  // ---------- Pointer handling ----------
  void _handlePointerDown(PointerDownEvent e) {
    _pointers[e.pointer] = e.localPosition;

    // when exactly 2 fingers touch => start 2-finger mode + tap candidate
    if (_pointers.length == 2) {
      _setTwoFingerMode(true);
      _lastTwoFingerCentroid = _centroidOfTwo();
      _scrollCarry = 0.0;

      _startTwoFingerTapCandidate();
    } else if (_pointers.length > 2) {
      // more than two fingers => cancel tap candidate
      _cancelTwoFingerTapCandidate();
    }
  }

  void _handlePointerMove(PointerMoveEvent e) {
    if (!_pointers.containsKey(e.pointer)) return;
    _pointers[e.pointer] = e.localPosition;

    if (_pointers.length >= 2) {
      if (!_twoFingerMode) {
        _setTwoFingerMode(true);
        _lastTwoFingerCentroid = _centroidOfTwo();
        _scrollCarry = 0.0;
        _startTwoFingerTapCandidate();
        return;
      }

      final now = _centroidOfTwo();
      final last = _lastTwoFingerCentroid ?? now;
      final dy = now.dy - last.dy;
      _lastTwoFingerCentroid = now;

      // If user moved enough, it's scroll, not tap
      final tapStart = _twoFingerTapStartCentroid;
      if (_twoFingerTapCandidate && tapStart != null) {
        if ((now - tapStart).distance > _twoFingerTapMoveThresholdPx) {
          _twoFingerTapCandidate = false; // keep mode, just not a tap
        }
      }

      // Scroll
      final scrollScale = 0.10 * _sensitivity;
      _scrollCarry += dy * scrollScale;

      final steps = _scrollCarry.truncate();
      if (steps != 0) {
        _scrollCarry -= steps;
        widget.onScroll(steps);
      }
      return;
    }

    // 1 finger => move (also cancels any 2-finger tap)
    _cancelTwoFingerTapCandidate();
    if (_pointers.length == 1 && !_twoFingerMode) {
      _moveCursor(e.delta);
    }
  }

  void _handlePointerUpOrCancel(PointerEvent e) {
    _pointers.remove(e.pointer);

    // If we drop from 2 fingers to <2, we can decide if it was a 2-finger tap
    if (_pointers.length < 2) {
      // capture last centroid for movement check
      // (if we had 2 fingers previously, _lastTwoFingerCentroid is set)
      _setTwoFingerMode(false);
      _scrollCarry = 0.0;

      // If both fingers released quickly without moving => right click
      // We trigger when count becomes 0 to avoid firing early.
      if (_pointers.isEmpty) {
        _maybeFireTwoFingerTap();
      } else {
        // still 1 finger down, treat as not a 2-finger tap
        _cancelTwoFingerTapCandidate();
      }

      _lastTwoFingerCentroid = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
            
child: Stack(
  alignment: Alignment.center,
  children: [
    // LEFT
    Align(
      alignment: Alignment.centerLeft,
      child: _Pill(
        icon: Icons.arrow_back_ios_new,
        label: 'Back',
        tone: cs.primary,
        onTab: widget.onBack,
      ),
    ),

    // CENTER
    _Pill(
      icon: Icons.bluetooth_connected_outlined,
      label: 'Connected',
      tone: cs.secondary,
    ),

    // RIGHT
    Align(
      alignment: Alignment.centerRight,
      child: _Pill(
        icon: Icons.ads_click,
        label: '$_clicks',
        tone: cs.tertiary,
      ),
    ),
  ],
),          ),
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
                        child: Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: _handlePointerDown,
                          onPointerMove: _handlePointerMove,
                          onPointerUp: _handlePointerUpOrCancel,
                          onPointerCancel: _handlePointerUpOrCancel,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            // 1-finger tap = left click
                            onTap: _doLeftClick,
                            // keep long-press as right click too
                            onLongPress: _doRightClick,
                            onDoubleTap: () async {
                              await _doLeftClick();
                              await Future.delayed(
                                  const Duration(milliseconds: 30));
                              await _doLeftClick();
                            },
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),

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
                                'How to Use?\nDrag to move • Tap = left click • Two-finger tap = right click • Two-finger drag = scroll',
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
                        onPressed: _doLeftClick,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.more_horiz,
                        label: 'Right Click',
                        onPressed: _doRightClick,
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
   _Pill({required this.icon, required this.label, required this.tone, this.onTab});

  final IconData icon;
  final String label;
  final Color tone;
  VoidCallback? onTab;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTab,
      child: Container(
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