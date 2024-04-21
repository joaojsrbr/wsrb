import 'package:animations/animations.dart';
import 'package:app_wsrb_jsr/app/core/services/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        final ThemeController themeController = context.read<ThemeController>();

        return SharedAxisTransition(
          fillColor: themeController.transitionPageFillColor,
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
