import 'dart:collection';

import 'package:flutter/material.dart';

class ValueNotifierList extends ChangeNotifier with ListBase<String> {
  late final List<String> _array;

  ValueNotifierList() {
    _array = [];
  }

  ValueNotifierList.from(Iterable<String> elements, {bool growable = true}) {
    _array = List.from(elements, growable: growable);
  }

  void toggle(String id) {
    if (!contains(id)) {
      add(id);
    } else {
      remove(id);
    }
    notifyListeners();
  }

  @override
  void add(String element) {
    _array.add(element);
  }

  @override
  int get length => _array.length;

  @override
  set length(int newLength) => _array.length = newLength;

  @override
  String operator [](int index) => _array[index];

  @override
  void operator []=(int index, String value) => _array[index] = value;

  @override
  void clear() {
    super.clear();
    notifyListeners();
  }
}
