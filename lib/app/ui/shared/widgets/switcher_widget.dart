import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

class SwitcherWidget extends StatelessWidget {
  const SwitcherWidget({
    super.key,
    this.children = const [SizedBox.shrink()],
    this.duration,
    this.index = 1,
  });

  final List<Widget> children;
  final Duration? duration;
  final int index;

  @override
  Widget build(BuildContext context) {
    final index = this.index - 1;
    final children = this.children.mapIndexed(
      (index, e) => KeyedSubtree(key: ObjectKey("${e.runtimeType}_$index"), child: e),
    );
    final widget = children.elementAt(index);

    return duration != null
        ? AnimatedSwitcher(duration: duration!, child: widget)
        : widget;
  }
}
