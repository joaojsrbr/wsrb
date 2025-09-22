import 'routes/routes.dart';
import 'ui/shared/widgets/global_overlay.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = true;
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    customLog('$this[build]');

    final light = ColorScheme.fromSeed(
      seedColor: const Color(0xFF191724),
      brightness: Brightness.light,
    );
    final dark = ColorScheme.fromSeed(
      seedColor: const Color(0xFF191724),
      brightness: Brightness.dark,
    );

    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: light,
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
        splashFactory: InkRipple.splashFactory,
        useSystemColors: true,
      ),
      darkTheme: ThemeData(
        colorScheme: dark,
        splashFactory: InkRipple.splashFactory,
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
        useSystemColors: true,
      ),
      themeMode: ThemeMode.system,
      supportedLocales: const [Locale('pt')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => AppNotificationOverlay(child: child!),
      debugShowCheckedModeBanner: false,
      routerDelegate: appRouter.routerDelegate,
      routeInformationParser: appRouter.routeInformationParser,
      routeInformationProvider: appRouter.routeInformationProvider,
    );
  }
}

/// Rosé Pine Moon — palette colors from rose-pine/palette :contentReference[oaicite:2]{index=2}
class RosePineMoonColors {
  static const Color base = Color(0xFF232136);
  static const Color surface = Color(0xFF2A273F);
  static const Color overlay = Color(0xFF393552);
  static const Color muted = Color(0xFF6E6A86);
  static const Color subtle = Color(0xFF908CAA);
  static const Color text = Color(0xFFE0DEF4);
  static const Color love = Color(0xFFEB6F92);
  static const Color gold = Color(0xFFF6C177);
  static const Color rose = Color(0xFFEA9A97);
  static const Color pine = Color(0xFF3E8FB0);
  static const Color foam = Color(0xFF9CCFD8);
  static const Color iris = Color(0xFFC4A7E7);
  static const Color highlightLow = Color(0xFF2A283E);
  static const Color highlightMed = Color(0xFF44415A);
  static const Color highlightHigh = Color(0xFF56526E);
}
