import 'dart:collection';

import 'package:flutter/material.dart';

class QuickSort<E> extends ListBase<E> {
  List<E> _array = [];

  QuickSort() {
    int high = _array.length - 1;
    int low = 0;
    _quickSort(this, low, high);
  }

  QuickSort.from(Iterable<E> elements) {
    int high = elements.length - 1;
    int low = 0;
    _array = _quickSort(elements.toList(), low, high);
  }

  @override
  int get length => _array.length;
  // @override
  // int get length {
  //   int high = _array.length - 1;
  //   int low = 0;
  //   _quickSort(_array, low, high);
  //   return _array.length;
  // }

  @override
  set length(int newLength) => _array.length = newLength;

  @override
  void operator []=(int index, E value) => _array[index] = value;

  @override
  E operator [](int index) => _array[index];

  List<E> _quickSort(List<E> list, int low, int high) {
    if (low < high) {
      int pi = _partition(list, low, high);
      debugPrint("pivot: ${list[pi]} now at index $pi");

      _quickSort(list, low, pi - 1);
      _quickSort(list, pi + 1, high);
      return list;
    }
    return list;
  }

  int _partition(List<E> list, low, high) {
    // Base check
    if (list.isEmpty) return 0;
    // Take our last element as pivot and counter i one less than low
    // E pivot = list[high];
    E pivot = list[high];

    int i = low - 1;
    for (int j = low; j < high; j++) {
      // When j is < than pivot element we increment i and swap arr[i] and arr[j]
      if (list[j] != pivot) {
        i++;
        _swap(list, i, j);
      }
    }
    // Swap the last element and place in front of the i'th element
    _swap(list, i + 1, high);
    return i + 1;
  }

  // Swapping using a temp variable
  void _swap(List<E> list, int i, int j) {
    E temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }
}
