import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:quiver/iterables.dart' as quiver;

import '../../content_library.dart';

class Releases extends ListBase<Release> with EquatableMixin {
  Releases() {
    _array = [];
  }

  Releases.fromList(Iterable<Release> contents) {
    _array = List.from(contents);
  }

  late List<Release> _array;

  List<Releases> partition(int size) {
    return quiver
        .partition(reversed.toList(), size)
        .map(Releases.fromList)
        .toList();
  }

  @override
  Releases toList({bool growable = true}) {
    return Releases.fromList(this);
  }

  @override
  Release operator [](int index) => _array[index];

  @override
  void add(Release element) {
    return _array.add(element);
  }

  @override
  void operator []=(int index, Release value) => _array[index] = value;

  @override
  int get length => _array.length;

  @override
  set length(int newLength) => _array.length = newLength;

  @override
  List<Object?> get props => this;
}
