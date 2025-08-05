import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:quiver/iterables.dart' as quiver;

import '../../content_library.dart';

class Releases<T extends Release> extends ListBase<T> with EquatableMixin {
  Releases();

  Releases.fromList(Iterable<Release> contents) {
    _array.addAll(contents.cast());
  }

  List<Map<String, dynamic>> get toMap {
    return map<Map<String, dynamic>>(
      (e) => switch (e) {
        Chapter data => data.toMap,
        Episode data => data.toMap,
        _ => {},
      },
    ).toList();
  }

  final List<T> _array = [];

  List<Releases> partition(int size) {
    return quiver.partition(reversed.toList(), size).map(Releases.fromList).toList();
  }

  @override
  Releases<T> toList({bool growable = true}) {
    return Releases.fromList(this);
  }

  @override
  T operator [](int index) => _array[index];

  @override
  void sort([int Function(T a, T b)? compare]) {
    _array.sort((release1, release2) => release1.compareTo(release2));
  }

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

  UnmodifiableListView<Episode> get _sorted {
    return UnmodifiableListView(_array.sortedBy<num>((episode) => episode.numberInt));
  }

  @override
  Episode operator [](int index) => _sorted[index];

  @override
  void operator []=(int index, Episode value) => _array[index] = value;
}

class ChapterReleases extends Releases<Chapter> {
  ChapterReleases() : super();

  UnmodifiableListView<Chapter> get _sorted {
    return UnmodifiableListView(
      _array.sortedBy<num>((episode) => int.parse(episode.number)),
    );
  }

  @override
  Chapter operator [](int index) => _sorted[index];

  ChapterReleases.from(super.contents) : super.fromList();
}
