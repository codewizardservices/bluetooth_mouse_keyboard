import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../control/mini_keyboard.dart';

class KeyboardPage extends StatefulWidget {
  final ValueChanged<String> onKeyPressed; // 👈 callback

  const KeyboardPage({super.key, required this.onKeyPressed});

  @override
  State<KeyboardPage> createState() => _KeyboardPageState();
}

class _KeyboardPageState extends State<KeyboardPage> {
  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations(const [
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF06131A),
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.6),
                    radius: 1.25,
                    colors: [
                      cs.surface.withOpacity(0.35),
                      const Color(0xFF06131A),
                    ],
                  ),
                ),
              ),
            ),

            // Keyboard
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: MiniKeyboard(
                  onKeyPressed: (k) {
  widget.onKeyPressed(k); // 👈 send key back
},
                ),
              ),
            ),

            // Positioned(
            //   left: 12,
            //   top: 12,
            //   child: Material(
            //     color: Colors.white.withOpacity(0.08),
            //     borderRadius: BorderRadius.circular(999),
            //     child: InkWell(
            //       borderRadius: BorderRadius.circular(999),
            //       onTap: () => Navigator.pop(context),
            //       child: const Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Icon(
            //               Icons.arrow_back_rounded,
            //               color: Colors.white,
            //               size: 13,
            //             ),
            //             SizedBox(width: 8),
            //             Text(
            //               "Back",
            //               style: TextStyle(color: Colors.white, fontSize: 10),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            
            // Positioned(
            //   right: 15,
            //   top: 12,
            //   child: Material(
            //     color: Colors.white.withOpacity(0.08),
            //     borderRadius: BorderRadius.circular(999),
            //     child: InkWell(
            //       borderRadius: BorderRadius.circular(999),
            //       onTap: () => Navigator.pop(context),
            //       child: const Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Icon(Icons.info, color: Colors.white, size: 13),
            //             SizedBox(width: 8),
            //             Text(
            //               "Info",
            //               style: TextStyle(color: Colors.white, fontSize: 10),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          
          ],
        ),
      ),
    );
  }
}
