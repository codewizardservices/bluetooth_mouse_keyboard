import 'package:flutter/material.dart';

class OrangeCornerShine extends StatefulWidget {
  const OrangeCornerShine({
    super.key,
    this.width = 150,
    this.height = 200,
    this.assetPath = 'assets/icon.png',
    this.duration = const Duration(milliseconds: 1500),
    this.intensity = 0.55, // 0.2 .. 0.9
    this.bandWidth = 0.08, // 0.03 .. 0.18 (thickness of shine)
  });

  final double width;
  final double height;
  final String assetPath;
  final Duration duration;
  final double intensity;
  final double bandWidth;

  @override
  State<OrangeCornerShine> createState() => _OrangeCornerShineState();
}

class _OrangeCornerShineState extends State<OrangeCornerShine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final h = widget.height;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ Real icon stays original
          Image.asset(widget.assetPath, fit: BoxFit.contain),

          // ✅ Orange shine overlay (masked to icon)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                // Move from -1.2 to +1.2 so it starts/ends off-screen
                final t = _c.value * 2.4 - 1.2;

                final mid = 0.5;
                final half = widget.bandWidth / 2;
                final s1 = (mid - half).clamp(0.0, 1.0);
                final s2 = mid.clamp(0.0, 1.0);
                final s3 = (mid + half).clamp(0.0, 1.0);

                return Opacity(
                  opacity: widget.intensity,
                  child: ShaderMask(
                    blendMode:
                        BlendMode.srcIn, // show shine only on icon pixels
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight, // corner-to-corner
                        colors: const [
                          Colors.transparent,
                          Color(0xFFFF7A00), // orange shine
                          Colors.transparent,
                        ],
                        stops: [s1, s2, s3],
                        transform: _SlideDiagonal(t),
                      ).createShader(rect);
                    },
                    child: Image.asset(
                      widget.assetPath,
                      fit: BoxFit.contain,
                      // this makes the mask work cleanly
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideDiagonal extends GradientTransform {
  const _SlideDiagonal(this.t);
  final double t; // -1.2 .. +1.2

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * t, bounds.height * t, 0);
  }
}
