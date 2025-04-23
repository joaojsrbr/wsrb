import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

class CustomPopup<E> extends StatefulWidget {
  const CustomPopup({
    super.key,
    required this.show,
    required this.items,
    required this.height,
    required this.width,
    this.duration,
    this.reverseDuration,
    this.color,
    this.shape,
    this.startAnimatedAlignment = Alignment.topCenter,
    this.scrollDirection = Axis.vertical,
    this.paddingTop = false,
    required this.builderFunction,
  }) : builder = null;

  const CustomPopup.builder({
    super.key,
    required this.show,
    required this.height,
    this.color,
    required this.width,
    this.startAnimatedAlignment = Alignment.topCenter,
    this.duration,
    this.reverseDuration,
    this.shape,
    this.scrollDirection = Axis.vertical,
    this.paddingTop = false,
    required this.builder,
  })  : builderFunction = null,
        items = const [];

  final bool paddingTop;
  final Axis scrollDirection;
  final Alignment startAnimatedAlignment;
  final bool show;
  final Color? color;
  final Duration? duration;
  final Duration? reverseDuration;
  final ShapeBorder? shape;
  final List<E> items;
  final Widget Function(BuildContext context)? builder;
  final Widget Function(BuildContext context, int index, E item)?
      builderFunction;

  final double height;
  final double width;

  @override
  State<CustomPopup<E>> createState() => _CustomPopupState<E>();
}

class _CustomPopupState<E> extends State<CustomPopup<E>>
    with TickerProviderStateMixin {
  late final ScrollController _localController;
  final Debouncer _debouncer =
      Debouncer(duration: const Duration(milliseconds: 250));
  final Debouncer _debouncerShowWiget =
      Debouncer(duration: const Duration(milliseconds: 250));
  late final AnimationController _animationController;
  late Animation<double> _animationHeight;
  late Animation<double> _animationWidth;

  bool _show = false;
  bool _showWidget = false;

  @override
  void initState() {
    _show = widget.show;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 300),
      reverseDuration:
          widget.reverseDuration ?? const Duration(milliseconds: 300),
    )..addListener(_animationShowWidgetListener);

    _localController = ScrollController();

    _animationHeight = _animationController.drive(Tween(
      begin: 0.0,
      end: widget.height,
    ));

    _animationWidth = Tween(
      begin: 0.0,
      end: widget.width,
    ).animate(_animationHeight);

    scheduleMicrotask(_init);
    super.initState();
  }

  void _animationShowWidgetListener() {
    if (_animationController.value > 0.8) {
      _debouncer.call(() {
        setState(() {
          _showWidget = true;
        });
      });
    } else {
      _debouncer.call(() {
        setState(() {
          _showWidget = false;
        });
      });
    }
  }

  void _init() async {
    // await Future.delayed(const Duration(milliseconds: 350));
    if (widget.show) {
      _animationController.forward();
    }
    scheduleMicrotask(_scrollToTop);
  }

  @override
  void didUpdateWidget(covariant CustomPopup<E> oldWidget) {
    // if (widget.duration != oldWidget.duration) {
    //   _animationController.duration = widget.duration;
    // }

    if (widget.height != oldWidget.height) {
      _animationHeight = _animationController.drive(Tween(
        begin: 0.0,
        end: widget.height,
      ));
    }
    if (widget.width != oldWidget.width) {
      _animationWidth = Tween(
        begin: 0.0,
        end: widget.width,
      ).animate(_animationHeight);
    }

    if (oldWidget.show != widget.show) {
      _animationController.toggle();
      _show = widget.show;

      // _show = widget.show;
    }

    super.didUpdateWidget(oldWidget);
  }

  void _scrollToTop() async {
    if (!_localController.hasClients) return;

    await Future.delayed(const Duration(milliseconds: 400));

    await _localController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastEaseInToSlowEaseOut,
    );
  }

  @override
  void dispose() {
    _debouncerShowWiget.cancel();
    _debouncer.cancel();
    _localController.dispose();
    _animationController
      ..removeListener(_animationShowWidgetListener)
      ..dispose();
    _animationHeight;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_animationHeight, _animationWidth]),
      builder: (context, child) => Align(
        alignment: widget.startAnimatedAlignment,
        child: Offstage(
          offstage: !_show && !_showWidget,
          child: AnimatedContainer(
            width: _animationWidth.value,
            height: _animationHeight.value,
            duration: widget.duration ?? const Duration(milliseconds: 150),
            curve: Curves.fastOutSlowIn,
            child: Card(
              margin: EdgeInsets.zero,
              shape: widget.shape,
              elevation: 3,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeLeft: true,
                removeRight: true,
                child: Builder(
                  builder: (context) {
                    return widget.builder != null
                        ? FadeTransition(
                            opacity: _animationController,
                            child: !_showWidget
                                ? const SizedBox.shrink()
                                : widget.builder!(context),
                          )
                        : ListView.builder(
                            primary: false,
                            padding: EdgeInsets.only(
                              top: widget.paddingTop ? padding.top : 0,
                              right: 0,
                              left: 0,
                              bottom: 0,
                            ),
                            controller: _localController,
                            scrollDirection: widget.scrollDirection,
                            itemCount: widget.items.length,
                            itemBuilder: (context, index) {
                              return FadeTransition(
                                opacity: _animationController,
                                child: !_showWidget
                                    ? const SizedBox.shrink()
                                    : widget.builderFunction!(
                                        context,
                                        index,
                                        widget.items[index],
                                      ),
                              );
                            },
                          );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
