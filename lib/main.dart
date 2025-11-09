import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_frontend/features/authentication/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚙️ Inicializa o window_manager apenas se for desktop
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows)) {
    await windowManager.ensureInitialized();

    // ✅ Obtém tamanho da tela principal
    final display = await screenRetriever.getPrimaryDisplay();
    final screenSize = display.size;

    // Define tamanho proporcional (ex: 30% da largura e 80% da altura)
    final width = screenSize.width * 0.3;
    final height = screenSize.height * 0.9;

    const title = 'Aura Corretora Imobiliária';

    final windowOptions = WindowOptions(
      size: Size(width, height),
      center: true,
      backgroundColor: Colors.transparent,
      title: title,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setSize(Size(width, height));
      await windowManager.center();
      await windowManager.setResizable(true);
      await windowManager.setIcon('assets/icones/icone3.png');
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
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
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginPage(),
    );
  }
}
