import 'dart:async';

import 'package:flutter/material.dart';

class CustomPopup<E> extends StatefulWidget {
  const CustomPopup({
    super.key,
    required this.show,
    required this.items,
    this.height,
    this.width,
    this.duration,
    this.shape,
    this.paddingTop = false,
    required this.builderFunction,
  });
  final bool paddingTop;
  final bool show;
  final Duration? duration;
  final ShapeBorder? shape;
  final List<E> items;
  final Function(BuildContext context, int index, E item) builderFunction;
  final double? height;
  final double? width;

  @override
  State<CustomPopup<E>> createState() => _CustomPopupState<E>();
}

class _CustomPopupState<E> extends State<CustomPopup<E>> {
  late final ScrollController _localController;

  bool _delayShow = false;

  @override
  void initState() {
    _delayShow = widget.show;
    _localController = ScrollController();
    scheduleMicrotask(_scrollToTop);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomPopup<E> oldWidget) {
    if (oldWidget.show != widget.show) {
      if (oldWidget.show) {
        Timer(const Duration(milliseconds: 300), () {
          _delayShow = widget.show;
        });
      } else {
        _delayShow = widget.show;
      }
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
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Offstage(
      offstage: !_delayShow,
      child: AnimatedContainer(
        width: widget.show ? widget.width ?? 110 : 0,
        height: widget.show
            ? widget.height ?? MediaQuery.of(context).size.height / 1.4
            : 0,
        duration: widget.duration ?? const Duration(milliseconds: 300),
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
            child: ListView.builder(
              primary: false,
              padding: EdgeInsets.only(
                top: widget.paddingTop ? padding.top : 0,
                right: 0,
                left: 0,
                bottom: 0,
              ),
              controller: _localController,
              scrollDirection: Axis.vertical,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return widget.builderFunction(
                  context,
                  index,
                  widget.items[index],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }
}
