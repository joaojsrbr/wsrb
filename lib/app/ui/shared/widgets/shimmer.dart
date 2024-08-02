import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget({
    super.key,
    this.child,
    this.borderRadius = BorderRadius.zero,
    this.clipper,
    this.height,
    this.width,
  });
  final CustomClipper<RRect>? clipper;
  final BorderRadiusGeometry borderRadius;
  final Widget? child;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ClipRRect(
        clipper: clipper,
        borderRadius: borderRadius,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade200,
          child: child ??
              ((width != null || height != null)
                  ? SizedBox(
                      height: height,
                      width: width,
                      child: const Material(),
                    )
                  : const SizedBox.expand(child: Material())),
        ),
      );
    });
  }
}
