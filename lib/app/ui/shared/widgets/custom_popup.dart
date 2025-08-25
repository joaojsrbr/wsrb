import 'dart:async';

import 'package:flutter/material.dart';

/// A compact, efficient popup that animates its width/height and fades
/// its children in only when the expansion is mostly complete.
class CustomPopup<E> extends StatefulWidget {
  /// Constructor for a list-backed popup (itemBuilder).
  const CustomPopup.items({
    super.key,
    required this.show,
    required this.items,
    required this.itemBuilder,
    required this.height,
    required this.width,
    this.duration,
    this.reverseDuration,
    this.color,
    this.shape,
    this.startAnimatedAlignment = Alignment.topCenter,
    this.scrollDirection = Axis.vertical,
    this.paddingTop = false,
    this.card = true,
  }) : builder = null;

  /// Constructor for a single-builder popup.
  const CustomPopup.builder({
    super.key,
    required this.show,
    required this.builder,
    required this.height,
    required this.width,
    this.duration,
    this.reverseDuration,
    this.color,
    this.shape,
    this.startAnimatedAlignment = Alignment.topCenter,
    this.scrollDirection = Axis.vertical,
    this.paddingTop = false,
    this.card = true,
  }) : items = const [],
       itemBuilder = null;

  final bool paddingTop;
  final Axis scrollDirection;
  final Alignment startAnimatedAlignment;
  final bool show;
  final Color? color;
  final bool card;
  final Duration? duration;
  final Duration? reverseDuration;
  final ShapeBorder? shape;

  final List<E> items;
  final Widget? builder;
  final Widget Function(BuildContext context, int index, E item)? itemBuilder;

  final double height;
  final double width;

  @override
  State<CustomPopup<E>> createState() => _CustomPopupState<E>();
}

class _CustomPopupState<E> extends State<CustomPopup<E>> with TickerProviderStateMixin {
  late final ScrollController _localController;

  late final AnimationController _controller;
  late Animation<double> _animationHeight;
  late Animation<double> _animationWidth;
  late Animation<double> _fadeIn;

  final _SimpleDebouncer _debouncer = _SimpleDebouncer(milliseconds: 120);

  bool _showInner = false;

  @override
  void initState() {
    super.initState();

    _localController = ScrollController();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 300),
      reverseDuration: widget.reverseDuration ?? const Duration(milliseconds: 300),
    );

    _initAnimations();

    if (widget.show) {
      _controller.value = 1.0;
      _showInner = true;
    } else {
      _controller.value = 0.0;
      _showInner = false;
    }

    _controller.addListener(_controllerListener);
  }

  void _initAnimations() {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);

    _animationHeight = Tween(begin: 0.0, end: widget.height).animate(curved);
    _animationWidth = Tween(begin: 0.0, end: widget.width).animate(curved);

    _fadeIn = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  void _controllerListener() {
    final shouldShowInner = _controller.value > 0.8;
    if (shouldShowInner != _showInner) {
      _debouncer.call(() {
        if (!mounted) return;
        setState(() => _showInner = shouldShowInner);
      });
    }
  }

  @override
  void didUpdateWidget(covariant CustomPopup<E> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.height != oldWidget.height || widget.width != oldWidget.width) {
      _initAnimations();
    }

    if (oldWidget.show != widget.show) {
      if (widget.show) {
        _controller.forward();
        scheduleMicrotask(_scrollToTop);
      } else {
        _controller.reverse();
      }
    }
  }

  Future<void> _scrollToTop() async {
    if (!_localController.hasClients) return;

    await Future.delayed(const Duration(milliseconds: 120));

    if (!_localController.hasClients) return;

    try {
      await _localController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.fastOutSlowIn,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _localController.dispose();
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final width = _animationWidth.value;
        final height = _animationHeight.value;

        final isVisible = _controller.value > 0.001;

        Widget content;
        if (widget.builder != null) {
          content = widget.builder!;
        } else {
          content = ListView.builder(
            primary: false,
            padding: EdgeInsets.only(
              top: widget.paddingTop ? padding.top : 0,
              right: 0,
              left: 0,
              bottom: 0,
            ),
            shrinkWrap: true,
            controller: _localController,
            scrollDirection: widget.scrollDirection,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              if (!_showInner) return const SizedBox.shrink();
              return widget.itemBuilder!(context, index, widget.items[index]);
            },
          );
        }

        return Align(
          alignment: widget.startAnimatedAlignment,
          child: Offstage(
            offstage: !isVisible,
            child: SizedBox(
              width: width,
              height: height,
              child: widget.card
                  ? Card(
                      margin: EdgeInsets.zero,
                      shape: widget.shape,
                      elevation: 3,
                      color: widget.color,
                      child: FadeTransition(opacity: _fadeIn, child: content),
                    )
                  : FadeTransition(opacity: _fadeIn, child: content),
            ),
          ),
        );
      },
    );
  }
}

class _SimpleDebouncer {
  _SimpleDebouncer({required int milliseconds})
    : _duration = Duration(milliseconds: milliseconds);

  final Duration _duration;
  Timer? _timer;

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(_duration, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
