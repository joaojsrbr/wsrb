import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:quiver/iterables.dart' as quiver;

import '../../content_library.dart';

/// Coleção ordenada e única de [Release].
///
/// Internamente usa [SplayTreeSet] para manter os elementos ordenados.
/// Exige que [T] implemente [Comparable] ou que seja fornecido um [Comparator].
class Releases<T extends Release> extends ListBase<T> with EquatableMixin {
  Releases({int Function(T a, T b)? compare}) : _array = SplayTreeSet<T>(compare);

  Releases.fromList(Iterable<T> contents, {int Function(T a, T b)? compare})
    : _array = SplayTreeSet<T>(compare) {
    _array.addAll(contents);
  }

  final SplayTreeSet<T> _array;

  /// Converte todos os releases em lista de mapas.
  List<Map<String, dynamic>> get toMap => map((e) => e.toMap()).toList();

  /// Adiciona ou atualiza múltiplos itens.
  /// Se [isSame] retornar `true`, o item existente é substituído.
  void addOrUpdateMany(Iterable<T> items, bool Function(T existing, T newItem) isSame) {
    for (final item in items) {
      final index = indexWhere((e) => isSame(e, item));
      if (index != -1) {
        this[index] = item;
      } else {
        add(item);
      }
    }
  }

  /// Divide os releases em blocos de [size].
  List<Releases<T>> partition(int size) {
    return quiver
        .partition(toList(), size)
        .map((chunk) => Releases.fromList(chunk))
        .toList();
  }

  @override
  Releases<T> toList({bool growable = true}) => Releases.fromList(this);

  @override
  T operator [](int index) => _array.elementAt(index);

  @override
  void operator []=(int index, T value) {
    final copy = List<T>.from(_array);
    copy[index] = value;
    _array
      ..clear()
      ..addAll(copy); // ordena automaticamente
  }

  @override
  void add(T element) => _array.add(element);

  @override
  void sort([int Function(T a, T b)? compare]) {
    // como já é um SplayTreeSet, basta recriar
    final copy = List<T>.from(_array)..sort(compare);
    _array
      ..clear()
      ..addAll(copy);
  }

  @override
  int get length => _array.length;

  @override
  set length(int newLength) {
    final copy = List<T>.from(_array)..length = newLength;
    _array
      ..clear()
      ..addAll(copy);
  }

  @override
  List<Object?> get props => toList();
}

/// Releases específicos de episódios.
class EpisodeReleases extends Releases<Episode> {
  EpisodeReleases({super.compare});

  EpisodeReleases.from(super.contents, {super.compare}) : super.fromList();
}

/// Releases específicos de capítulos.
class ChapterReleases extends Releases<Chapter> {
  ChapterReleases({super.compare});

  ChapterReleases.from(super.contents, {super.compare}) : super.fromList();
}
