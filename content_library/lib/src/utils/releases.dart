import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:quiver/iterables.dart' as quiver;

import '../../content_library.dart';

class Releases<T extends Release> extends ListBase<T> with EquatableMixin {
  Releases() {
    _array = [];
  }

  Releases.fromList(Iterable<Release> contents) {
    _array = List.from(contents);
  }

  late List<T> _array;

  List<Releases> partition(int size) {
    return quiver
        .partition(reversed.toList(), size)
        .map(Releases.fromList)
        .toList();
  }

  @override
  Releases<T> toList({bool growable = true}) {
    return Releases.fromList(this);
  }

  @override
  T operator [](int index) => _array[index];

  @override
  void add(T element) {
    _array.add(element);
    sort((release1, release2) => release1.compareTo(release2));
  }

  @override
  void operator []=(int index, T value) => _array[index] = value;

  @override
  int get length => _array.length;

  @override
  set length(int newLength) => _array.length = newLength;

  @override
  List<Object?> get props => this;
}

class EpisodeReleases extends Releases<Episode> {
  EpisodeReleases() : super();
  EpisodeReleases.from(super.contents) : super.fromList();
}

class ChapterReleases extends Releases<Chapter> {
  ChapterReleases() : super();

  ChapterReleases.from(super.contents) : super.fromList();
}
