import 'dart:async';

import 'package:flutter/widgets.dart';

/// A specialized [GlobalKey] that provides helper methods to interact with
/// the [Navigator].
///
/// It can be used to programmatically pop the route associated with the widget
/// this key is attached to, for instance, after a certain delay.
class Anchor<T extends State<StatefulWidget>> extends LabeledGlobalKey<T> {
  /// Creates an anchor key.
  /// The [debugLabel] is used for debugging purposes.
  Anchor({String? debugLabel}) : super(debugLabel);

  /// Schedules the route to be popped from the navigator after a given [duration].
  ///
  /// Defaults to a 5-second delay.
  /// Returns the [Timer] instance, allowing the operation to be cancelled.
  Timer autoPopAfterDelay([Duration duration = const Duration(seconds: 5)]) {
    return Timer(duration, _pop);
  }

  /// Finds the nearest [NavigatorState] from the widget tree.
  NavigatorState? get _navigatorState {
    if (currentContext == null) return null;
    return Navigator.maybeOf(currentContext!);
  }

  /// Pops the current route from the navigator stack.
  void _pop() => _navigatorState?.pop();
}
