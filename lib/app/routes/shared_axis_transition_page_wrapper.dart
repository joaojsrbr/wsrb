import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class SharedAxisTransitionPageWrapper extends Page {
  const SharedAxisTransitionPageWrapper({
    this.screen,
    this.screenBuilder,
    required ValueKey transitionKey,
    super.arguments,
  }) : super(key: transitionKey);

  final Widget? screen;

  final WidgetBuilder? screenBuilder;

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 650),
      reverseTransitionDuration: const Duration(milliseconds: 650),
      settings: this,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          fillColor: Theme.of(context).canvasColor,
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
