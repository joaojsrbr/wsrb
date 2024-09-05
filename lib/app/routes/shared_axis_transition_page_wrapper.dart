import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class SharedAxisTransitionPageWrapper extends Page {
  const SharedAxisTransitionPageWrapper({
    this.screen,
    this.screenBuilder,
    this.transitionDuratio,
    this.reverseTransitionDuration,
    super.restorationId,
    required ValueKey transitionKey,
    super.arguments,
  }) : super(key: transitionKey);

  final Widget? screen;

  final Duration? transitionDuratio;
  final Duration? reverseTransitionDuration;

  final WidgetBuilder? screenBuilder;

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      transitionDuration:
          transitionDuratio ?? const Duration(milliseconds: 650),
      reverseTransitionDuration:
          reverseTransitionDuration ?? const Duration(milliseconds: 650),
      settings: this,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          fillColor: Theme.of(context).cardColor,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        // OpenContainer;
        return screenBuilder?.call(context) ??
            screen ??
            const SizedBox.shrink();
      },
    );
  }
}
