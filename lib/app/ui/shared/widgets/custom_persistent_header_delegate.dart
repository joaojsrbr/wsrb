import 'package:flutter/material.dart';

class CustomPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget Function(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
    double progress,
  )
  buildWidget;

  final bool Function(
    CustomPersistentHeaderDelegate oldDelegate,
    CustomPersistentHeaderDelegate delegate,
  )?
  delegateShouldRebuild;

  const CustomPersistentHeaderDelegate({
    required this.maxExtent,
    required this.minExtent,
    required this.buildWidget,
    this.delegateShouldRebuild,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return buildWidget(
      context,
      shrinkOffset,
      overlapsContent,
      shrinkOffset / maxExtent,
    );
  }

  @override
  final double minExtent;

  @override
  final double maxExtent;

  @override
  bool shouldRebuild(covariant CustomPersistentHeaderDelegate oldDelegate) {
    return delegateShouldRebuild?.call(oldDelegate, this) ?? true;
  }
}
