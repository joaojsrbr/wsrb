import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class CustomOverlayState<T extends StatefulWidget> extends State<T>
    with SingleTickerProviderStateMixin<T> {
  bool get reverseAnimation;

  Duration get animationDuration => const Duration(milliseconds: 750);

  late Animation<Offset> _overlayAnimation;

  late final AnimationController _overlayAnimationController;

  Animation<Offset> get animation => _overlayAnimation;

  Animation<double> get curved => CurvedAnimation(
    parent: _overlayAnimationController,
    curve: Curves.ease,
    reverseCurve: Curves.ease,
  );

  Offset? begin;

  Offset? end;

  @override
  void initState() {
    super.initState();
    _overlayAnimationController =
        AnimationController(vsync: this, duration: animationDuration)
          ..addStatusListener(animationStatusListener)
          ..addListener(animationListener);

    Offset offset = const Offset(0, 1);

    if (reverseAnimation) offset = const Offset(0, -1);

    _overlayAnimation = Tween(
      begin: begin ?? offset,
      end: end ?? Offset.zero,
    ).animate(curved);
    scheduleMicrotask(onStartAnimation);
  }

  void changeAnimation({required Offset begin, Offset end = Offset.zero}) {
    _overlayAnimation = Tween(begin: begin, end: end).animate(curved);
  }

  TickerFuture forward() => _overlayAnimationController.forward();
  TickerFuture reverse() => _overlayAnimationController.reverse();

  @override
  void didUpdateWidget(covariant T oldWidget) {
    didAnimation(widget, oldWidget);
    super.didUpdateWidget(oldWidget);
  }

  void didAnimation(T widget, T oldWidget);

  void onStartAnimation() {}

  void animationListener() {}

  void animationStatusListener(AnimationStatus status) {}

  @override
  void dispose() {
    _overlayAnimationController
      ..removeStatusListener(animationStatusListener)
      ..removeListener(animationListener)
      ..dispose();
    super.dispose();
  }
}
