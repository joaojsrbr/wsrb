import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

/// Um controller que gerencia um valor e notifica os ouvintes quando ele muda.
/// Use o tipo genérico [T] para definir o tipo do valor (ex: int, String, etc.).
class HighlightController<T extends Object> extends ChangeNotifier {
  final Map<T, Timer> _active = {};

  HighlightController();

  Duration _duration = Duration.zero;

  void toggle(T newValue) {
    void remove() {
      _active[newValue]?.cancel();
      _active.remove(newValue);
    }

    if (_active.keys.contains(newValue)) {
      remove();
    } else {
      _active[newValue] = Timer(_duration, remove);
    }

    notifyListeners();
  }

  bool isActive(T value) => _active.keys.contains(value);
}

class CustomHighlight extends StatefulWidget {
  const CustomHighlight({super.key, this.controller, required this.child});

  final HighlightController? controller;
  final Widget child;

  @override
  State<CustomHighlight> createState() => _CustomHighlightState();

  static HighlightController of(BuildContext context) {
    return _CustomHighlightScope.of(context);
  }

  static HighlightController? maybeOf(BuildContext context) {
    return _CustomHighlightScope.maybeOf(context);
  }
}

class _CustomHighlightState extends State<CustomHighlight> {
  late final HighlightController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? HighlightController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _CustomHighlightScope(notifier: _controller, child: widget.child);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _CustomHighlightScope extends InheritedNotifier<HighlightController> {
  const _CustomHighlightScope({required super.child, required super.notifier});

  static HighlightController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_CustomHighlightScope>()!.notifier!;
  }

  static HighlightController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_CustomHighlightScope>()?.notifier;
  }

  @override
  bool updateShouldNotify(_CustomHighlightScope oldWidget) {
    return {
      notifier != oldWidget.notifier,
      // notifier?._value != oldWidget.notifier?._value,
    }.contains(true);
  }
}

class CustomValueChangeHighlight extends StatelessWidget {
  const CustomValueChangeHighlight({
    super.key,
    required this.child,
    required this.value,
    this.color,
    this.useInitialHighLight = false,
    this.duration = const Duration(milliseconds: 500),
    this.padding = EdgeInsets.zero,
  });
  final Widget child;
  final bool useInitialHighLight;
  final Duration duration;
  final String value;
  final Color? color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final controller = _CustomHighlightScope.maybeOf(context);
    controller?._duration = duration;
    final enable = controller?.isActive(value) ?? false;
    return SmoothHighlight(
      useInitialHighLight: useInitialHighLight,
      padding: padding,
      enabled: enable,
      color: color ?? Theme.of(context).colorScheme.primary.withAlpha(38),
      child: child,
    );
  }
}
