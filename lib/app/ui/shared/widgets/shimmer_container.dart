// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerContainer extends StatelessWidget {
  const ShimmerContainer({
    super.key,
    this.width = double.infinity,
    this.height,
    this.enable = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(2)),
    required this.child,
  });
  final Widget child;
  final double width;
  final bool enable;
  final double? height;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height,
      child: enable
          ? Shimmer.fromColors(
              baseColor: theme.colorScheme.onSurface.withOpacity(0.4),
              highlightColor: theme.colorScheme.onSurface.withOpacity(0.3),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  borderRadius: borderRadius,
                ),
              ),
            )
          : child,
    );
  }
}
