import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../control/mini_keyboard_layout.dart';
import '../control/mini_keycap.dart';

class MiniKeyboard extends StatefulWidget {
  const MiniKeyboard({super.key, required this.onKeyPressed});

  final ValueChanged<String> onKeyPressed;

  @override
  State<MiniKeyboard> createState() => _MiniKeyboardState();
}

class _MiniKeyboardState extends State<MiniKeyboard> {
  bool _fnLayer = false;

  Future<void> _haptic() async {
    await HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AspectRatio(
      // Reference image is ~1000x354 => ~2.82
      aspectRatio: 2.82,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF14171A),
              const Color(0xFF0F1113),
              const Color(0xFF0A0B0D),
            ],
          ),
          border: Border.all(color: cs.primary.withOpacity(0.18), width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 18),
              color: Colors.black.withOpacity(0.5),
            ),
          ],
        ),
        child: Column(
          children: [
            for (final row in const [
              MiniKeyboardLayout.row1,
              MiniKeyboardLayout.row2,
              MiniKeyboardLayout.row3,
              MiniKeyboardLayout.row4,
            ])
              Expanded(
                child: Row(
                  children: [
                    for (final k in row)
                      Expanded(
                        flex: k.flex,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: MiniKeycap(
                            keyData: k,
                            onPressed: () async {
                              await _haptic();
                              // Fn toggles the secondary (cyan) layer.
                              if (k.primary == 'Fn') {
                                setState(() => _fnLayer = !_fnLayer);
                                return;
                              }

                              final secondary = (k.secondary ?? '').trim();
                              final out = (_fnLayer && secondary.isNotEmpty)
                                  ? secondary
                                  : k.primary;

                              widget.onKeyPressed(out);
                            },
                            isActive: k.primary == 'Fn' && _fnLayer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
