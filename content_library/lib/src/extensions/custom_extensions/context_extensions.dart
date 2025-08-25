import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  void unFocusKeyBoard() {
    final FocusScopeNode currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.focusedChild?.unfocus();
    }
  }

  /// Calculates memCacheHeight and memCacheWidth for an image based on display height,
  /// optional width or aspect ratio, and device pixel ratio (DPR).
  ///
  /// Parameters:
  /// - [displayHeight]: The height at which the image is displayed (logical pixels).
  /// - [displayWidth]: Optional display width (logical pixels). If null, aspectRatio is used.
  /// - [aspectRatio]: Optional aspect ratio (width/height). Defaults to 16:9 if not provided.
  /// - [optimizeMemory]: If true, uses logical pixel size; if false, scales by DPR for sharp rendering.
  ///
  /// Returns: A [Size] with memCacheWidth and memCacheHeight.
  Size calculateImageCacheSize({
    required double displayHeight,
    double? displayWidth,
    double? aspectRatio,
    bool optimizeMemory = false,
  }) {
    // Get device pixel ratio
    final double dpr = MediaQuery.of(this).devicePixelRatio;

    // Calculate memCacheHeight
    final double memCacheHeight = optimizeMemory ? displayHeight : displayHeight * dpr;

    // Calculate memCacheWidth
    double memCacheWidth;
    if (displayWidth != null) {
      // Use provided display width
      memCacheWidth = optimizeMemory ? displayWidth : displayWidth * dpr;
    } else {
      // Use aspect ratio (default to 16:9 if not provided)
      final double effectiveAspectRatio = aspectRatio ?? 16 / 9;
      final double calculatedWidth = displayHeight * effectiveAspectRatio;
      memCacheWidth = optimizeMemory ? calculatedWidth : calculatedWidth * dpr;
    }

    return Size(memCacheWidth, memCacheHeight);
  }

  /// Calculates memCacheHeight and memCacheWidth for an image based on BoxConstraints,
  /// optional aspect ratio, and device pixel ratio (DPR).
  ///
  /// Parameters:
  /// - [constraints]: BoxConstraints defining the layout bounds (max/min width/height).
  /// - [aspectRatio]: Optional aspect ratio (width/height). Defaults to 16:9 if not provided.
  /// - [optimizeMemory]: If true, uses logical pixel size; if false, scales by DPR for sharp rendering.
  ///
  /// Returns: A [Size] with memCacheWidth and memCacheHeight.
  Size calculateImageCacheSizeByBoxConstraints({
    required BoxConstraints constraints,
    double? aspectRatio,
    bool optimizeMemory = false,
  }) {
    // Get device pixel ratio
    final double dpr = MediaQuery.of(this).devicePixelRatio;

    // Determine effective display height and width from constraints
    double displayHeight = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : constraints.minHeight;
    double displayWidth;

    if (constraints.maxWidth.isFinite) {
      displayWidth = constraints.maxWidth;
    } else if (constraints.minWidth > 0) {
      displayWidth = constraints.minWidth;
    } else {
      // Fallback to aspect ratio if width is unconstrained
      final double effectiveAspectRatio = aspectRatio ?? 16 / 9;
      displayWidth = displayHeight * effectiveAspectRatio;
    }

    // Calculate memCacheHeight
    final double memCacheHeight = optimizeMemory ? displayHeight : displayHeight * dpr;

    // Calculate memCacheWidth
    final double memCacheWidth = optimizeMemory ? displayWidth : displayWidth * dpr;

    return Size(memCacheWidth.roundToDouble(), memCacheHeight.roundToDouble());
  }
}
