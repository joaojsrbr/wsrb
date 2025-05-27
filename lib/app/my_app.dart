import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:content_library/content_library.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = true;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    customLog('$this[build]');

    return MaterialApp.router(
      theme: FlexThemeData.light(
        scheme: FlexScheme.purpleM3,
        useMaterial3ErrorColors: true,
        applyElevationOverlayColor: true,
        variant: FlexSchemeVariant.vibrant,
      ).copyWith(),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.purpleM3,
        useMaterial3ErrorColors: true,
        applyElevationOverlayColor: true,
        variant: FlexSchemeVariant.vibrant,
      ).copyWith(),
      themeMode: ThemeMode.system,
      supportedLocales: const [Locale('pt')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      routerDelegate: appRoutes.routerDelegate,
      routeInformationParser: appRoutes.routeInformationParser,
      routeInformationProvider: appRoutes.routeInformationProvider,
    );
  }
}
