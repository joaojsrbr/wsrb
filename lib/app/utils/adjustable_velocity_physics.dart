import 'package:flutter/material.dart';

class AdjustableVelocityScrollPhysics extends ScrollPhysics {
  final double speedMultiplier;

  const AdjustableVelocityScrollPhysics({
    super.parent,
    required this.speedMultiplier,
  });

  @override
  AdjustableVelocityScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return AdjustableVelocityScrollPhysics(
        parent: buildParent(ancestor), speedMultiplier: speedMultiplier);
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity * speedMultiplier,
    );
  }
}
