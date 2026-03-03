import 'package:bluetoothairmousekeyboard/admob/ad_state_provider.dart';
import 'package:bluetoothairmousekeyboard/in_app_purchase/InAppPurchaseProvider.dart';
import 'package:bluetoothairmousekeyboard/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => InAppPurchaseProvider()),
        ChangeNotifierProvider(create: (context) => AdStateProvider()),
      ],child: const RemoteUiApp()));
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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Remote UI',
      theme: base.copyWith(
        textTheme: GoogleFonts.interTextTheme(base.textTheme),
      ),
      routerConfig: router,
    );
  }
}

