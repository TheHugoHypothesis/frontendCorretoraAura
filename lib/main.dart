import 'package:aura_frontend/screens/ProprietarioListPage.dart';
import 'package:aura_frontend/screens/adquirente_list_page.dart';
import 'package:aura_frontend/screens/adquirente_management.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart'; // necessário para detectar a plataforma
import 'package:window_manager/window_manager.dart';

// Telas
import 'package:aura_frontend/screens/cadastro_page.dart';
import 'package:aura_frontend/screens/contract_registration_page.dart';
import 'package:aura_frontend/screens/home.dart';
import 'package:aura_frontend/screens/login_page.dart';
import 'package:aura_frontend/screens/propriety_registration_page.dart';
import 'package:aura_frontend/screens/onboarding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚙️ Inicializa o window_manager apenas se for desktop
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows)) {
    await windowManager.ensureInitialized();
    await windowManager.setResizable(true);

    const windowOptions = WindowOptions(
      size: Size(450, 844), // tamanho tipo celular
      center: true,
      backgroundColor: Colors.transparent,
      title: 'Aura Corretora Imobiliária',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setSize(const Size(450, 844));
      await windowManager.center();
      await windowManager.setResizable(true);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Corretora Imobiliária',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.grey,
          surface: Colors.white,
          onSurface: Colors.black87,
          background: Colors.white,
          onBackground: Colors.black87,
        ),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displaySmall: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          titleLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          bodyLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ProprietarioListPage(),
    );
  }
}
