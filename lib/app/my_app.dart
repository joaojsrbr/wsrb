import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = true;

    final ThemeController themeController = context.watch<ThemeController>();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return MaterialApp.router(
      themeMode: themeController.themeMode,
      restorationScopeId: 'root',
      darkTheme: themeController.darkTheme,
      supportedLocales: const [Locale('en', 'US'), Locale('pt')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: themeController.lightTheme,
      debugShowCheckedModeBanner: false,
      routerDelegate: appRoutes.routerDelegate,
      routeInformationParser: appRoutes.routeInformationParser,
      routeInformationProvider: appRoutes.routeInformationProvider,
    );
  }
}
