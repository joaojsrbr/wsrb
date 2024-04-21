import 'package:content_library/content_library.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'color_schemes.g.dart';

class ThemeController extends ChangeNotifier {
  final HiveService _hiveService;

  ThemeController(this._hiveService);

  Color? _transitionPageFillColor;

  ColorScheme? _lightSystemColorScheme;
  ColorScheme? _darkSystemColorScheme;

  late ThemeMode _themeMode;
  late bool _systemThemeMode;

  static const _defaultValueThemeMode = HiveDefaultValue(
    'theme_service_themeMode',
    ThemeMode.dark,
  );

  static const _defaultValueSystemThemeMode = HiveDefaultValue(
    'theme_service_system_theme_mode',
    false,
  );

  ThemeMode get themeMode => _themeMode;
  Color? get transitionPageFillColor => _transitionPageFillColor;
  bool get systemThemeMode => _systemThemeMode;

  void setTransitionPageFillColor(Color? value) {
    if (value == _transitionPageFillColor) return;
    _transitionPageFillColor = value;
  }

  Future<void> setThemeMode(ThemeMode? value, [bool notify = true]) async {
    if (value == null || value == _themeMode) return;
    _themeMode = value;
    if (notify) notifyListeners();
    await _hiveService.save(_defaultValueThemeMode.key, value);
  }

  Future<void> setSystemThemeMode(bool? value, [bool notify = true]) async {
    if (value == null || value == _systemThemeMode) return;
    _systemThemeMode = value;
    if (notify) notifyListeners();
    await _hiveService.save(_defaultValueSystemThemeMode.key, value);
  }

  Future<void> loadAll() async {
    final result = await Future.wait([
      _hiveService.load(
        _defaultValueThemeMode.key,
        _defaultValueThemeMode.defaultValue,
      ),
      _hiveService.load(
        _defaultValueSystemThemeMode.key,
        _defaultValueSystemThemeMode.defaultValue,
      ),
    ]);

    _themeMode = result.elementAt(0) as ThemeMode;
    _systemThemeMode = result.elementAt(1) as bool;
    await _getSystemColorScheme();
  }

  ColorScheme get _lightColorScheme {
    if (_systemThemeMode) {
      return (_lightSystemColorScheme ?? _gLightColorScheme).harmonized();
    }
    return _gLightColorScheme.harmonized();
  }

  ColorScheme get _darkColorScheme {
    if (_systemThemeMode) {
      return (_darkSystemColorScheme ?? _gDarkColorScheme).harmonized();
    }
    return _gDarkColorScheme.harmonized();
  }

  Future<void> _getSystemColorScheme() async {
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();

      if (corePalette != null) {
        customLog('dynamic_color: Core palette detected.');

        _lightSystemColorScheme = corePalette.toColorScheme();
        _darkSystemColorScheme = corePalette.toColorScheme(
          brightness: Brightness.dark,
        );

        return;
      }
    } on PlatformException {
      customLog('dynamic_color: Failed to obtain core palette.');
    }

    try {
      final Color? accentColor = await DynamicColorPlugin.getAccentColor();

      if (accentColor != null) {
        debugPrint('dynamic_color: Accent color detected.');

        _lightSystemColorScheme = ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.light,
        );
        _darkSystemColorScheme = ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
        );

        return;
      }
    } on PlatformException {
      customLog('dynamic_color: Failed to obtain accent color.');
    }

    customLog('dynamic_color: Dynamic color not detected on this device.');
  }

  void forceUpdate() {
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
        buttonTheme: buttonTheme(_lightColorScheme),
        splashFactory: InkRipple.splashFactory,
        useMaterial3: true,
        scaffoldBackgroundColor: _lightColorScheme.background,
        applyElevationOverlayColor: true,
        brightness: Brightness.light,
        textButtonTheme: _textButtonTheme(_lightColorScheme),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(8),
          thumbColor: MaterialStatePropertyAll(_lightColorScheme.primary),
        ),
        colorScheme: _lightColorScheme,
      );

  ThemeData get darkTheme => ThemeData(
        buttonTheme: buttonTheme(_darkColorScheme),
        splashFactory: InkRipple.splashFactory,
        useMaterial3: true,
        scaffoldBackgroundColor: _darkColorScheme.background,
        applyElevationOverlayColor: true,
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(8),
          thumbColor: MaterialStatePropertyAll(_darkColorScheme.primary),
        ),
        brightness: Brightness.dark,
        textButtonTheme: _textButtonTheme(_darkColorScheme),
        colorScheme: _darkColorScheme,
      );

  ButtonThemeData buttonTheme(ColorScheme colorScheme) {
    return ButtonThemeData(
      shape: _defaultShape.resolve({}),
      colorScheme: colorScheme,
    );
  }

  TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: _OverlayColor(colorScheme),
        shape: _defaultShape,
      ),
    );
  }

  MaterialStateProperty<OutlinedBorder?> get _defaultShape {
    return MaterialStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _OverlayColor extends MaterialStateProperty<Color?> {
  _OverlayColor(this.colorScheme);

  final ColorScheme colorScheme;

  @override
  Color? resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      return colorScheme.primary.withOpacity(0.12);
    } else if (states.contains(MaterialState.hovered)) {
      return colorScheme.primary.withOpacity(0.08);
    } else if (states.contains(MaterialState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }
}
