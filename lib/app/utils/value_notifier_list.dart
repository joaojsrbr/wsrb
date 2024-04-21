import 'dart:collection';

import 'package:flutter/material.dart';

class ValueNotifierList extends ValueNotifier<HashSet<String>> {
  ValueNotifierList() : super(HashSet());

  bool contains(String id) => value.contains(id);
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;
  int get length => value.length;

  void toggle(String id) {
    if (!value.contains(id)) {
      value.add(id);
    } else {
      value.remove(id);
    }
    notifyListeners();
  }

  void clear() {
    value.clear();
    notifyListeners();
  }
}
