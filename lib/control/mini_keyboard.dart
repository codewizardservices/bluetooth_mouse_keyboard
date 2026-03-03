import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ------------------------------------------------------------
/// Mini Keyboard (single-file) - like your screenshot
///
/// Fixes requested:
/// 1) Bigger font for alphabets/symbols + centered in the key
/// 2) Enter (↩) key looks like a “primary action” (blue-ish style)
/// 3) When Caps (⇧) is ON, the letters shown on the keyboard become UPPERCASE
///
/// Output mapping:
/// - Space key: " "
/// - Enter: "\n"
/// - Backspace: "\b"
/// ------------------------------------------------------------

enum KeycapStyle { round, pill, longPill }

class MiniKeycapData {
  const MiniKeycapData(
    this.primary, {
    this.secondary,
    this.style = KeycapStyle.round,
    this.flex = 1,
  });

  final String primary;
  final String? secondary;
  final KeycapStyle style;
  final int flex;
}

class MiniKeycap extends StatefulWidget {
  const MiniKeycap({
    super.key,
    required this.keyData,
    required this.onPressed,
    this.isActive = false,
  });

  final MiniKeycapData keyData;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  State<MiniKeycap> createState() => _MiniKeycapState();
}

class _MiniKeycapState extends State<MiniKeycap> {
  bool _down = false;

  bool _isControlKey(String s) => const {'⇧', '⌫', '↩', '␣', '123?', 'ABC', '◀', '▶'}.contains(s);

  bool _isEnterKey(String s) => s == '↩';

  // single visible character (letters/symbols/digits) -> make it larger
  bool _isBigGlyph(String s) {
    if (s.length != 1) return false;
    if (_isControlKey(s)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.keyData;

    const accent = Color(0xFF33D3FF);
    const enterAccent = Color(0xFF2F5B7A); // blue-ish like screenshot

    final isEnter = _isEnterKey(k.primary);

    final borderColor = widget.isActive
        ? accent.withOpacity(0.85)
        : (isEnter ? enterAccent.withOpacity(0.8) : const Color(0xFF2B2F33).withOpacity(0.9));

    final border = Border.all(color: borderColor, width: widget.isActive ? 1.3 : 1);

    final bg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: widget.isActive
          ? [const Color(0xFF2C3136), const Color(0xFF14181B)]
          : isEnter
              ? [const Color(0xFF2E4E63), const Color(0xFF203746)]
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

    final br = shape.borderRadius as BorderRadius;

    final base = Theme.of(context).textTheme.labelSmall;
    final baseSize = base?.fontSize ?? 12;

    final big = _isBigGlyph(k.primary);

    final primaryStyle = base?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: 0.1,
      height: 1.0,
      color: Colors.white.withOpacity(0.92),
      fontSize: big ? (baseSize + 4.0) : (baseSize + 1.0),
    );

    return AnimatedScale(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      scale: _down ? 0.97 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: br,
          onHighlightChanged: (v) => setState(() => _down = v),
          onTap: widget.onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: bg,
              border: border,
              borderRadius: br,
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
                if (isEnter && !_down)
                  BoxShadow(
                    blurRadius: 16,
                    offset: const Offset(0, 0),
                    color: enterAccent.withOpacity(0.20),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: br,
              child: Stack(
                children: [
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Stack(
                      children: [
                        // ALWAYS centered now
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            k.primary,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: primaryStyle,
                          ),
                        ),
                        if ((k.secondary ?? '').isNotEmpty)
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              k.secondary!,
                              style: base?.copyWith(
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

class MiniKeyboard extends StatefulWidget {
  const MiniKeyboard({super.key, required this.onKeyPressed});
  final ValueChanged<String> onKeyPressed;

  @override
  State<MiniKeyboard> createState() => _MiniKeyboardState();
}

class _MiniKeyboardState extends State<MiniKeyboard> {
  bool _caps = false;     // toggled by ⇧ in ALPHA mode
  bool _symbols = false;  // toggled by 123?/ABC

  Future<void> _haptic() async => HapticFeedback.selectionClick();

  bool _isSingleLetter(String s) {
    if (s.length != 1) return false;
    final c = s.codeUnitAt(0);
    return (c >= 65 && c <= 90) || (c >= 97 && c <= 122);
  }

  String _applyCapsIfNeeded(String out) {
    if (_symbols) return out;
    if (!_isSingleLetter(out)) return out;
    return _caps ? out.toUpperCase() : out.toLowerCase();
  }

  String _emitForKey(String k) {
    return switch (k) {
      '␣' => ' ',
      '↩' => 'ENTER',
      '⌫' => 'DEL',
      _ => k,
    };
  }

  List<List<MiniKeycapData>> _layout() => _symbols ? _symbolLayout() : _alphaLayout();

  // NOTE: letters shown change with _caps (requested)
  List<List<MiniKeycapData>> _alphaLayout() {
    String L(String s) => _caps ? s.toUpperCase() : s.toLowerCase();

    return [
      [
        MiniKeycapData(L('q')),
        MiniKeycapData(L('w')),
        MiniKeycapData(L('e')),
        MiniKeycapData(L('r')),
        MiniKeycapData(L('t')),
        MiniKeycapData(L('y')),
        MiniKeycapData(L('u')),
        MiniKeycapData(L('i')),
        MiniKeycapData(L('o')),
        MiniKeycapData(L('p')),
      ],
      [
        MiniKeycapData(L('a')),
        MiniKeycapData(L('s')),
        MiniKeycapData(L('d')),
        MiniKeycapData(L('f')),
        MiniKeycapData(L('g')),
        MiniKeycapData(L('h')),
        MiniKeycapData(L('j')),
        MiniKeycapData(L('k')),
        MiniKeycapData(L('l')),
        const MiniKeycapData('.'),
      ],
      [
        const MiniKeycapData('⇧'),
        MiniKeycapData(L('z')),
        MiniKeycapData(L('x')),
        MiniKeycapData(L('c')),
        MiniKeycapData(L('v')),
        MiniKeycapData(L('b')),
        MiniKeycapData(L('n')),
        MiniKeycapData(L('m')),
        const MiniKeycapData(','),
        const MiniKeycapData('⌫'),
      ],
      const [
        MiniKeycapData('123?'),
        MiniKeycapData('◀'),
        MiniKeycapData('▶'),
        MiniKeycapData('␣', style: KeycapStyle.longPill, flex: 3),
        MiniKeycapData('-'),
        MiniKeycapData('_'),
        MiniKeycapData('↩'),
      ],
    ];
  }

  List<List<MiniKeycapData>> _symbolLayout() {
    return [
      const [
        MiniKeycapData('1', secondary: '!'),
        MiniKeycapData('2', secondary: '@'),
        MiniKeycapData('3', secondary: '#'),
        MiniKeycapData('4', secondary: r'$'),
        MiniKeycapData('5', secondary: '%'),
        MiniKeycapData('6', secondary: '^'),
        MiniKeycapData('7', secondary: '&'),
        MiniKeycapData('8', secondary: '*'),
        MiniKeycapData('9', secondary: '('),
        MiniKeycapData('0', secondary: ')'),
      ],
      const [
        MiniKeycapData('@'),
        MiniKeycapData('#'),
        MiniKeycapData(r'$'),
        MiniKeycapData('%'),
        MiniKeycapData('&'),
        MiniKeycapData('*'),
        MiniKeycapData('('),
        MiniKeycapData(')'),
        MiniKeycapData('"'),
        MiniKeycapData("'"),
      ],
      const [
        MiniKeycapData('⇧'),
        MiniKeycapData('!'),
        MiniKeycapData('?'),
        MiniKeycapData('/'),
        MiniKeycapData(':'),
        MiniKeycapData(';'),
        MiniKeycapData('+'),
        MiniKeycapData('='),
        MiniKeycapData(','),
        MiniKeycapData('⌫'),
      ],
      const [
        MiniKeycapData('ABC'),
        MiniKeycapData('◀'),
        MiniKeycapData('▶'),
        MiniKeycapData('␣', style: KeycapStyle.longPill, flex: 3),
        MiniKeycapData('-'),
        MiniKeycapData('_'),
        MiniKeycapData('↩'),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rows = _layout();

    return AspectRatio(
      aspectRatio: 2.82,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF14171A),
              Color(0xFF0F1113),
              Color(0xFF0A0B0D),
            ],
          ),
          border: Border.all(color: cs.primary.withOpacity(0.18), width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              offset: const Offset(0, 18),
              color: Colors.black.withOpacity(0.5),
            ),
          ],
        ),
        child: Column(
          children: [
            for (final row in rows)
              Expanded(
                child: Row(
                  children: [
                    for (final key in row)
                      Expanded(
                        flex: key.flex,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: MiniKeycap(
                            keyData: key,
                            isActive: (key.primary == '⇧' && _caps && !_symbols) ||
                                ((key.primary == '123?' && !_symbols) ||
                                    (key.primary == 'ABC' && _symbols)),
                            onPressed: () async {
                              await _haptic();

                              if (key.primary == '123?' || key.primary == 'ABC') {
                                setState(() => _symbols = !_symbols);
                                return;
                              }

                              if (key.primary == '⇧') {
                                if (!_symbols) setState(() => _caps = !_caps);
                                return;
                              }

                              final out = _applyCapsIfNeeded(_emitForKey(key.primary));
                              widget.onKeyPressed(out);
                            },
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