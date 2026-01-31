import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

mixin AutoDisposeMixin<T extends StatefulWidget> on State<T> {
  List<Object> get autoDispose;

  @override
  void dispose() {
    super.dispose();
    for (final obj in autoDispose) {
      _callDisposeIfPossible(obj);
    }
  }

  void _callDisposeIfPossible(Object obj) {
    try {
      switch (obj) {
        case Timer _:
          obj.cancel();
        case Subscriptions _:
          obj.cancelAll();
        case ChangeNotifier _:
          obj.dispose();
      }

      if (obj is StreamSubscription) {
        obj.cancel();
      }
    } catch (_) {}
  }
}
