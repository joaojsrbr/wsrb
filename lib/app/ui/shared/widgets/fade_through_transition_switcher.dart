import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FadeThroughTransitionSwitcher extends StatelessWidget {
  const FadeThroughTransitionSwitcher({
    super.key,
    this.fillColor = Colors.transparent,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.replace = false,
    this.secondChild = const SizedBox.shrink(),
  });

  final Widget child;
  final Widget secondChild;
  final Duration duration;
  final bool replace;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: duration,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return FadeThroughTransition(
          fillColor: fillColor,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: replace
          ? KeyedSubtree(
              key: ValueKey('$runtimeType secondChild'),
              child: secondChild,
            )
          : KeyedSubtree(
              key: ValueKey('$runtimeType firstChild'),
              child: child,
            ),
    );
  }
}
