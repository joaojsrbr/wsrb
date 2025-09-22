import 'dart:collection';

import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

class ValueNotifierList extends ChangeNotifier with ListBase<String> {
  late final List<String> _array;

  ValueNotifierList() {
    _array = [];
  }

  ValueNotifierList.from(Iterable<String> elements, {bool growable = true}) {
    _array = List.from(elements, growable: growable);
  }

  bool toggle(String id) {
    bool result = false;
    if (!contains(id)) {
      add(id);
      result = false;
    } else {
      result = remove(id);
    }
    notifyListeners();
    return result;
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
    _array.clear();
    notifyListeners();
  }

  @override
  void removeListener(VoidCallback listener) {
    _array.clear();
    super.removeListener(listener);
  }

  @override
  bool contains(Object? element) {
    return switch (element) {
      Release data => _array.contains(data.stringID),
      Content data => _array.contains(data.stringID),
      ContentEntity data => _array.contains(data.stringID),
      _ => super.contains(element),
    };
  }
}
