import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

class FlipCardWithSpring extends StatefulWidget {
  const FlipCardWithSpring({
    super.key,
    required this.isFlipped,
    required this.active,
    this.size = const Size(200, 300),
    this.frontWidget = const Center(child: Text('Front')),
    this.backWidget = const Center(child: FlutterLogo(size: 100)),
  });

  final bool isFlipped;
  final Size size;
  final bool active;
  final Widget frontWidget;
  final Widget backWidget;

  @override
  State<FlipCardWithSpring> createState() => _FlipCardWithSpringState();
}

class _FlipCardWithSpringState extends State<FlipCardWithSpring>
    with SingleTickerProviderStateMixin {
  late final MotionController<double> _controller;

  @override
  void initState() {
    super.initState();

    _controller = SingleMotionController(
      vsync: this,
      motion: const CupertinoMotion.bouncy(),
    );
  }

  @override
  void didUpdateWidget(covariant FlipCardWithSpring oldWidget) {
    if ((oldWidget.isFlipped != widget.isFlipped || oldWidget.active != widget.active) &&
        widget.active) {
      _controller.animateTo(widget.isFlipped ? 1 : 0);
    }
    if (oldWidget.active != widget.active) {
      if (!widget.active) {
        _controller.stop();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => _FlipCard(
        animationValue: _controller.value,
        frontWidget: widget.frontWidget,
        backWidget: widget.backWidget,
        size: widget.size,
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({
    required this.animationValue,
    required this.frontWidget,
    required this.backWidget,
    required this.size,
  });

  final double animationValue;
  final Widget frontWidget;
  final Widget backWidget;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final angle = pi * animationValue;
    Widget cardFace;
    if (angle <= pi / 2) {
      cardFace = SizedBox.fromSize(
        size: size,
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: frontWidget,
        ),
      );
    } else {
      cardFace = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(pi),
        child: SizedBox.fromSize(
          size: size,
          child: Card(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            child: backWidget,
          ),
        ),
      );
    }

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(angle),
      child: cardFace,
    );
  }
}
