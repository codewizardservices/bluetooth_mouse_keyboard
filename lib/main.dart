import 'package:bluetoothairmousekeyboard/pages/keyboard_page.dart';
import 'package:bluetoothairmousekeyboard/pages/touchpad_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RemoteUiApp());
}

class RemoteUiApp extends StatelessWidget {
  const RemoteUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xFF33D3FF),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Remote UI',
      theme: base.copyWith(
        textTheme: GoogleFonts.interTextTheme(base.textTheme),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // Touchpad only (keyboard will be fullscreen route)
  final _pages = const [TouchpadPage(), SizedBox.shrink()];

  @override
  void initState() {
    super.initState();
    _setPortrait();
  }

  Future<void> _setPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _openKeyboard() async {
    // Keep navbar selection on Touchpad
    setState(() => _index = 0);

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const KeyboardPage()));

    // After back: ensure Touchpad + portrait
    await _setPortrait();
    if (mounted) setState(() => _index = 0);
  }

  void _onTab(int next) {
    if (next == 1) {
      _openKeyboard();
      return;
    }
    setState(() => _index = 0);
    _setPortrait();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.touch_app_outlined),
            selectedIcon: Icon(Icons.touch_app),
            label: 'Touchpad',
          ),
          NavigationDestination(
            icon: Icon(Icons.keyboard_alt_outlined),
            selectedIcon: Icon(Icons.keyboard_alt),
            label: 'Keyboard',
          ),
        ],
      ),
    );
  }
}
