import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class SharedAxisTransitionPageWrapper extends Page {
  const SharedAxisTransitionPageWrapper({
    this.screen,
    this.screenBuilder,
    this.transitionDuration,
    this.reverseTransitionDuration,
    required ValueKey transitionKey,
    super.restorationId,
    super.arguments,
  }) : super(key: transitionKey);

  final Widget? screen;
  final WidgetBuilder? screenBuilder;

  final Duration? transitionDuration;
  final Duration? reverseTransitionDuration;

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      fullscreenDialog: true,
      transitionDuration: transitionDuration ?? const Duration(milliseconds: 700),
      reverseTransitionDuration:
          reverseTransitionDuration ?? const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
          reverseCurve: Curves.easeOutQuad,
        );
        final curvedSecondary = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.fastOutSlowIn,
          reverseCurve: Curves.easeInQuad,
        );

        return SharedAxisTransition(
          animation: curvedAnimation,
          secondaryAnimation: curvedSecondary,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) =>
          screenBuilder?.call(context) ?? screen ?? const SizedBox.shrink(),
    );
  }
}
