import 'dart:collection';

import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main ...', () async {
    final test = Test2<String>();

    test.addListener(() {
      customLog(test.value);
      customLog(test.value.length);
    });

    test.add('maria');
    test.add('joao');

    test[0] = 'luan';
    test.remove('joao');

    test.addAll(['test1', 'test2']);
  });
}

class Test2<T> extends ChangeNotifier with ListBase<T> {
  Test2({List<T>? value}) {
    _array = value ?? [];
  }

  late List<T> _array;

  List<T> get value => _array;

  @override
  T operator [](int index) => _array[index];

  @override
  void add(T element, {bool notify = true}) {
    _array.add(element);
    if (notify) notifyListeners();
  }

  @override
  bool remove(Object? element) {
    final result = super.remove(element);
    notifyListeners();
    return result;
  }

  @override
  void operator []=(int index, T value) {
    _array[index] = value;
    notifyListeners();
  }

  @override
  void addAll(Iterable<T> iterable) {
    _array.addAll(iterable);
    notifyListeners();
  }

  @override
  int get length => _array.length;

  @override
  set length(int newLength) => _array.length = newLength;
}
