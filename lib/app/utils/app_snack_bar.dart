import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

/// A utility class for showing snackbars.
///
/// This class provides static methods to display themed snackbars using the
/// `another_flushbar` package.
class AppSnackBar {
  // Private constructor to prevent instantiation.
  const AppSnackBar._();

  /// Displays a general-purpose snackbar.
  ///
  /// The snackbar is styled based on the application's [ThemeData].
  static Future<void> show(
    BuildContext context,
    Widget content, {
    FlushbarPosition flushbarPosition = FlushbarPosition.BOTTOM,
    FlushbarStyle flushbarStyle = FlushbarStyle.GROUNDED,
    Duration duration = const Duration(seconds: 2),
  }) async {
    if (!context.mounted) return;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final snackBarTheme = theme.snackBarTheme;

    // Use SnackBarThemeData if available, otherwise M3-like defaults.
    final backgroundColor =
        snackBarTheme.backgroundColor ??
        Color.lerp(colorScheme.surface, colorScheme.primary, 0.08)!;

    // For a tinted surface background, `onSurface` provides better contrast.
    final textStyle =
        snackBarTheme.contentTextStyle ??
        theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface);

    await Flushbar(
      backgroundColor: backgroundColor,
      flushbarPosition: flushbarPosition,
      duration: duration,
      flushbarStyle: flushbarStyle,
      messageText: DefaultTextStyle(style: textStyle!, child: content),
    ).show(context);
  }

  /// Displays an error snackbar.
  ///
  /// The snackbar is styled with error colors from the application's theme
  /// and is typically shown at the top of the screen.
  static Future<void> onError(BuildContext context, Object error) async {
    if (!context.mounted) return;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await Flushbar(
      backgroundColor: colorScheme.errorContainer,
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 4), // Longer duration for errors
      flushbarStyle: FlushbarStyle.GROUNDED,
      messageText: Text(
        error.toString().trim(),
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
    ).show(context);
  }
}

/// Extension on [BuildContext] to provide easy access to [AppSnackBar] methods.
extension AppSnackBarBuildContextExtensions on BuildContext {
  /// Shows a general-purpose snackbar.
  Future<void> showAppSnackBar(
    Widget content, {
    FlushbarPosition flushbarPosition = FlushbarPosition.BOTTOM,
    FlushbarStyle flushbarStyle = FlushbarStyle.GROUNDED,
    Duration duration = const Duration(seconds: 4),
  }) => AppSnackBar.show(
    this,
    content,
    flushbarPosition: flushbarPosition,
    flushbarStyle: flushbarStyle,
    duration: duration,
  );

  /// Shows an error snackbar.
  Future<void> showErrorSnackBar(Object error) =>
      AppSnackBar.onError(this, error);
}
