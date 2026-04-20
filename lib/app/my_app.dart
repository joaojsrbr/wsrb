import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'routes/routes.dart';
import 'ui/shared/widgets/global_overlay.dart';

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

    final appConfigController = context.watch<AppConfigController>();

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
      themeMode: appConfigController.config.themeMode,
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
