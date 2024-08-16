import 'package:content_library/content_library.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// part 'color_schemes.g.dart';
part 'theme.dart';

class ThemeController extends ChangeNotifier {
  final HiveService _hiveService;

  ThemeController(this._hiveService);

  ColorScheme? _lightSystemColorScheme;
  ColorScheme? _darkSystemColorScheme;

  late ThemeMode _themeMode;
  late Color _appColor;
  late bool _systemThemeMode;

  static const _defaultValueThemeMode = HiveDefaultValue(
    'theme_service_themeMode',
    ThemeMode.dark,
  );

  static const _defaultValueSystemThemeMode = HiveDefaultValue(
    'theme_service_system_theme_mode',
    false,
  );

  static const defaultValueAppColor = HiveDefaultValue(
    'theme_service_app_color',
    Color(0xff673ab7),
  );

  ThemeMode get themeMode => _themeMode;
  Color get appColor => _appColor;
  bool get systemThemeMode => _systemThemeMode;

  Future<void> setAppColor(Color? value, [bool notify = true]) async {
    if (value == null || value == _appColor) return;
    _appColor = value;
    if (notify) notifyListeners();
    await _hiveService.save(defaultValueAppColor.key, value);
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
    // await _getSystemColorScheme();

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
      _hiveService.load(
        defaultValueAppColor.key,
        defaultValueAppColor.defaultValue,
      ),
    ]);

    _themeMode = result.elementAt(0) as ThemeMode;
    _systemThemeMode = result.elementAt(1) as bool;
    _appColor = result.elementAt(2) as Color;
    await _getSystemColorScheme();
  }

  // ColorScheme get _lightScheme => MaterialTheme.lightScheme();

  // ColorScheme get _darkScheme => MaterialTheme.darkScheme();

  ColorScheme get _lightColorScheme {
    if (_systemThemeMode && _lightSystemColorScheme != null) {
      return ColorScheme.fromSeed(
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
        seedColor: _lightSystemColorScheme!.primary,
        primary: _lightSystemColorScheme!.primary,
        secondary: _lightSystemColorScheme!.secondary,
        brightness: Brightness.light,
      ).harmonized();
    }
    return ColorScheme.fromSeed(
      seedColor: _appColor,
      brightness: Brightness.light,
    ).harmonized();
    // if (_systemThemeMode && _lightSystemColorScheme != null) {
    //   return _lightSystemColorScheme!.harmonized();
    // }
    // return _lightScheme.harmonized();
  }

  ColorScheme get _darkColorScheme {
    if (_systemThemeMode && _darkSystemColorScheme != null) {
      return ColorScheme.fromSeed(
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
        seedColor: _darkSystemColorScheme!.primary,
        primary: _darkSystemColorScheme!.primary,
        secondary: _darkSystemColorScheme!.secondary,
        brightness: Brightness.dark,
      ).harmonized();
    }
    return ColorScheme.fromSeed(
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
      seedColor: _appColor,
      brightness: Brightness.dark,
    ).harmonized();
    // if (_systemThemeMode && _darkSystemColorScheme != null) {
    //   return _darkSystemColorScheme!.harmonized();
    // }
    // return _darkScheme.harmonized();
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

  TextTheme _textTheme(ColorScheme colorScheme) {
    return const TextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }

  ThemeData get lightTheme => const MaterialTheme().light().copyWith(
        cardTheme: CardTheme(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        colorScheme: _lightColorScheme,
        buttonTheme: _buttonTheme(_lightColorScheme),
        splashFactory: InkRipple.splashFactory,
        textTheme: _textTheme(_lightColorScheme),
        scaffoldBackgroundColor: _lightColorScheme.surface,
        canvasColor: _lightColorScheme.surface,
        applyElevationOverlayColor: true,
        brightness: Brightness.light,
        textButtonTheme: _textButtonTheme(_lightColorScheme),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(8),
          thumbColor: WidgetStatePropertyAll(_lightColorScheme.primary),
        ),
      );
  ThemeData get darkTheme => const MaterialTheme().dark().copyWith(
        colorScheme: _darkColorScheme,
        cardTheme: CardTheme(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        buttonTheme: _buttonTheme(_darkColorScheme),
        splashFactory: InkRipple.splashFactory,
        textTheme: _textTheme(_darkColorScheme),
        canvasColor: _darkColorScheme.surface,
        scaffoldBackgroundColor: _darkColorScheme.surface,
        applyElevationOverlayColor: true,
        brightness: Brightness.dark,
        textButtonTheme: _textButtonTheme(_darkColorScheme),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(8),
          thumbColor: WidgetStatePropertyAll(_darkColorScheme.primary),
        ),
      );

  ButtonThemeData _buttonTheme(ColorScheme colorScheme) {
    return ButtonThemeData(
      shape: _DefaultShape._value,
      colorScheme: colorScheme,
    );
  }

  TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: _OverlayColor(colorScheme),
        shape: _DefaultShape(),
      ),
    );
  }
}

class _DefaultShape extends WidgetStateProperty<OutlinedBorder?> {
  static OutlinedBorder get _value =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

  @override
  OutlinedBorder? resolve(Set<WidgetState> states) {
    return _value;
  }
}

class _OverlayColor extends WidgetStateProperty<Color?> {
  _OverlayColor(this.colorScheme);

  final ColorScheme colorScheme;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return colorScheme.primary.withOpacity(0.12);
    } else if (states.contains(WidgetState.hovered)) {
      return colorScheme.primary.withOpacity(0.08);
    } else if (states.contains(WidgetState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }
}
