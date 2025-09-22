import 'dart:async';

import '../../../utils/custom_states.dart';
import 'package:flutter/material.dart';

class PlayerCustomOverlay extends StatefulWidget {
  const PlayerCustomOverlay({
    super.key,
    required this.notifierChange,
    required this.begin,
    this.onTap,
    this.reversedBorder = false,
    this.enableCancelReversed = true,
    this.end = Offset.zero,
    this.reverseDuration = const Duration(seconds: 3),
  });

  final Offset begin;
  final bool enableCancelReversed;
  final Offset end;
  final bool reversedBorder;
  final ValueNotifier<String?> notifierChange;
  final Duration reverseDuration;
  final VoidCallback? onTap;

  @override
  CustomOverlayState createState() => _PlayerCustomOverlayState();
}

class _PlayerCustomOverlayState extends CustomOverlayState<PlayerCustomOverlay> {
  @override
  Offset? get begin => widget.begin;

  @override
  Offset? get end => widget.end;

  @override
  bool get reverseAnimation => false;

  // @override
  // Duration get animationDuration => const Duration(seconds: 3);

  Timer? _timer;

  String? _oldValue;

  @override
  void didAnimation(PlayerCustomOverlay widget, PlayerCustomOverlay oldWidget) {
    if (widget.begin != oldWidget.begin || widget.end != oldWidget.end) {
      changeAnimation(begin: widget.begin, end: widget.end);
    }
  }

  @override
  void initState() {
    super.initState();
    _notifierChange.addListener(_listener);
  }

  void _listener() async {
    if (_notifierChange.value == null) {
      await reverse();
      _oldValue = null;
    } else {
      if (widget.enableCancelReversed) _timer?.cancel();
      await forward();
      _oldValue = _notifierChange.value!;
      if (widget.enableCancelReversed) {
        _timer = Timer(widget.reverseDuration, () async {
          await reverse();
          _notifierChange.value = null;
        });
      }
    }
  }

  ValueNotifier<String?> get _notifierChange => widget.notifierChange;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    final isPortrait = orientation == Orientation.portrait;
    final defaultShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(
        right: widget.reversedBorder ? Radius.zero : const Radius.circular(12),
        left: widget.reversedBorder ? const Radius.circular(12) : Radius.zero,
      ),
    );
    Widget content = AnimatedBuilder(
      animation: _notifierChange,
      child: const SizedBox.shrink(),
      builder: (context, child) => _notifierChange.value != null
          ? Card(
              shape: defaultShape,
              margin: EdgeInsets.zero,
              child: InkWell(
                borderRadius: defaultShape.borderRadius as BorderRadius,
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _notifierChange.value!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            )
          : Card(
              shape: defaultShape,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _oldValue ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
    );

    if (isPortrait) content = SafeArea(child: content);

    return SlideTransition(position: animation, child: content);
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _notifierChange.removeListener(_listener);
  }
}
