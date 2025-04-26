import 'package:content_library/content_library.dart';

abstract class InRepository<E> {
  void updateRepository(Iterable<Iterable<E>> iterable) {
    _entities
      ..clear()
      ..addAll(iterable.flattened);
  }

  final List<E> _entities = [];

  UnmodifiableListView<E> get entities => UnmodifiableListView(_entities);
}
