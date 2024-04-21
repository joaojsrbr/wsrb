import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class AppSnackBar {
  const AppSnackBar(this._context);

  final BuildContext _context;
  // ignore: library_private_types_in_public_api
  _SnackbarDefaultsM3 get theme => _SnackbarDefaultsM3(_context);

  Future<void> onError(Object object) async {
    await Flushbar(
      backgroundColor: theme.backgroundColor,
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 2),
      flushbarStyle: FlushbarStyle.GROUNDED,
      message: object.toString().trim(),
    ).show(_context);
  }

  Future<void> show(
    Widget content, {
    FlushbarPosition flushbarPosition = FlushbarPosition.BOTTOM,
  }) async {
    await Flushbar(
      backgroundColor: theme.backgroundColor,
      flushbarPosition: flushbarPosition,
      duration: const Duration(seconds: 2),
      flushbarStyle: FlushbarStyle.GROUNDED,
      messageText: content,
    ).show(_context);
  }
}

extension BuildContextExtensions on BuildContext {
  AppSnackBar get appSnackBar => AppSnackBar(this);
}

class _SnackbarDefaultsM3 extends SnackBarThemeData {
  _SnackbarDefaultsM3(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color get backgroundColor =>
      Color.lerp(_colors.surface, _colors.primary, 0.08)!;

  @override
  Color get actionTextColor =>
      MaterialStateColor.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return _colors.inversePrimary;
        }
        if (states.contains(MaterialState.pressed)) {
          return _colors.inversePrimary;
        }
        if (states.contains(MaterialState.hovered)) {
          return _colors.inversePrimary;
        }
        if (states.contains(MaterialState.focused)) {
          return _colors.inversePrimary;
        }
        return _colors.inversePrimary;
      });

  @override
  Color get disabledActionTextColor => _colors.inversePrimary;

  @override
  TextStyle get contentTextStyle =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: _colors.onInverseSurface,
          );

  @override
  double get elevation => 6.0;

  @override
  ShapeBorder get shape => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)));

  @override
  SnackBarBehavior get behavior => SnackBarBehavior.fixed;

  @override
  EdgeInsets get insetPadding =>
      const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0);

  @override
  bool get showCloseIcon => false;

  @override
  Color? get closeIconColor => _colors.onInverseSurface;

  @override
  double get actionOverflowThreshold => 0.25;
}
