// import 'dart:math' as math;

// import 'package:flutter/material.dart';

// class CustomWidthSplashFactory extends InteractiveInkFeatureFactory {
//   final double splashWidth; // Fraction of tab width (0.0 to 1.0)
//   final double borderRadius;
//   final double borderWidth;

//   const CustomWidthSplashFactory({
//     required this.splashWidth,
//     required this.borderRadius,
//     required this.borderWidth,
//   });

//   @override
//   InteractiveInkFeature create({
//     required MaterialInkController controller,
//     required RenderBox referenceBox,
//     required Offset position,
//     required Color color,
//     required TextDirection textDirection,
//     bool containedInkWell = false,
//     RectCallback? rectCallback,
//     BorderRadius? borderRadius,
//     ShapeBorder? customBorder,
//     double? radius,
//     VoidCallback? onRemoved,
//   }) {
//     return CustomWidthInkSplash(
//       controller: controller,
//       referenceBox: referenceBox,
//       position: position,
//       textDirection: textDirection,
//       color: color,
//       splashWidth: splashWidth,
//       borderWidth: borderWidth,
//       borderRadius: this.borderRadius,
//       onRemoved: onRemoved,
//     );
//   }
// }

// const Duration _kUnconfirmedSplashDuration = Duration(seconds: 1);
// const Duration _kSplashFadeDuration = Duration(milliseconds: 200);

// const double _kSplashInitialSize = 0.0; // logical pixels
// const double _kSplashConfirmedVelocity = 1.0; // logical pixels per millisecond

// RectCallback? _getClipCallback(
//   RenderBox referenceBox,
//   bool containedInkWell,
//   RectCallback? rectCallback,
// ) {
//   if (rectCallback != null) {
//     assert(containedInkWell);
//     return rectCallback;
//   }
//   if (containedInkWell) {
//     return () => Offset.zero & referenceBox.size;
//   }
//   return null;
// }

// double _getTargetRadius(
//   RenderBox referenceBox,
//   bool containedInkWell,
//   RectCallback? rectCallback,
//   Offset position,
// ) {
//   if (containedInkWell) {
//     final Size size = rectCallback != null ? rectCallback().size : referenceBox.size;
//     return _getSplashRadiusForPositionInSize(size, position);
//   }
//   return Material.defaultSplashRadius;
// }

// double _getSplashRadiusForPositionInSize(Size bounds, Offset position) {
//   final double d1 = (position - bounds.topLeft(Offset.zero)).distance;
//   final double d2 = (position - bounds.topRight(Offset.zero)).distance;
//   final double d3 = (position - bounds.bottomLeft(Offset.zero)).distance;
//   final double d4 = (position - bounds.bottomRight(Offset.zero)).distance;
//   return math.max(math.max(d1, d2), math.max(d3, d4)).ceilToDouble();
// }

// class CustomWidthInkSplash extends InteractiveInkFeature {
//   CustomWidthInkSplash({
//     required MaterialInkController controller,
//     required RenderBox referenceBox,
//     required Offset position,
//     required Color color,
//     required double splashWidth,
//     required double borderWidth,
//     required double borderRadius,
//     required TextDirection textDirection,
//     VoidCallback? onRemoved,
//   }) : super(
//          controller: controller,
//          referenceBox: referenceBox,
//          color: color,
//          onRemoved: onRemoved,
//        ) {
//     final Size size = referenceBox.size;
//     final double effectiveWidth = (size.width - 2 * borderWidth) * splashWidth;
//     final double offsetX = (size.width - effectiveWidth) / 2;

//     final Rect splashRect = Rect.fromLTWH(
//       offsetX,
//       borderWidth,
//       effectiveWidth,
//       size.height - 2 * borderWidth,
//     );
//     _targetRadius = _getTargetRadius(referenceBox, true, () => splashRect, position);

//     final Path clipPath = Path()
//       ..addRRect(RRect.fromRectAndRadius(splashRect, Radius.circular(borderRadius)));

//     _splash = InkRipple(
//       textDirection: textDirection,
//       controller: controller,
//       referenceBox: referenceBox,
//       position: position,
//       color: color,
//       containedInkWell: true,
//       rectCallback: () => splashRect,
//       borderRadius: BorderRadius.circular(borderRadius),
//       customBorder: ClipPathShapeBorder(clipPath: clipPath),
//       radius: effectiveWidth * 0.5,
//       onRemoved: onRemoved,
//     );
//     _radiusController =
//         AnimationController(
//             duration: _kUnconfirmedSplashDuration,
//             vsync: controller.vsync,
//           )
//           ..addListener(controller.markNeedsPaint)
//           ..forward();
//     _radius = _radiusController.drive(
//       Tween<double>(
//         begin: _kSplashInitialSize,
//         end: _getTargetRadius(referenceBox, true, () => splashRect, position),
//       ),
//     );
//     _alphaController =
//         AnimationController(duration: _kSplashFadeDuration, vsync: controller.vsync)
//           ..addListener(controller.markNeedsPaint)
//           ..addStatusListener(_handleAlphaStatusChanged);
//     _alpha = _alphaController!.drive(IntTween(begin: color.alpha, end: 0));

//     // controller.addInkFeature(_splash);
//   }
//   late final double _targetRadius;

//   late Animation<double> _radius;

//   late AnimationController _radiusController;

//   late Animation<int> _alpha;
//   AnimationController? _alphaController;

//   late final InkRipple _splash;

//   void _handleAlphaStatusChanged(AnimationStatus status) {
//     if (status.isCompleted) {
//       dispose();
//     }
//   }

//   @override
//   void paintFeature(Canvas canvas, Matrix4 matrix) {
//     _splash.paintFeature(canvas, matrix);
//   }

//   @override
//   void confirm() {
//     final int duration = (_targetRadius / _kSplashConfirmedVelocity).floor();
//     _radiusController
//       ..duration = Duration(milliseconds: duration)
//       ..forward();
//     _alphaController!.forward();
//   }

//   @override
//   void cancel() {
//     _alphaController?.forward();
//   }

//   @override
//   void dispose() {
//     _radiusController.dispose();
//     _alphaController!.dispose();
//     _alphaController = null;
//     super.dispose();
//   }
// }

// class ClipPathShapeBorder extends ShapeBorder {
//   final Path clipPath;

//   const ClipPathShapeBorder({required this.clipPath});

//   @override
//   EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

//   @override
//   Path getInnerPath(Rect rect, {TextDirection? textDirection}) => clipPath;

//   @override
//   Path getOuterPath(Rect rect, {TextDirection? textDirection}) => clipPath;

//   @override
//   void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

//   @override
//   ShapeBorder scale(double t) => this;
// }
