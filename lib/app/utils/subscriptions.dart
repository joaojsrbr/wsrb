import 'dart:async';
import 'dart:collection';

class Subscriptions extends ListBase<StreamSubscription<dynamic>> {
  final List<StreamSubscription<dynamic>> _array =
      <StreamSubscription<dynamic>>[];

  @override
  StreamSubscription<dynamic> operator [](int index) => _array[index];

  @override
  void operator []=(int index, StreamSubscription<dynamic> value) =>
      _array[index] = value;

  @override
  int get length => _array.length;

  @override
  set length(int newLength) => _array.length = newLength;

  @override
  void add(StreamSubscription element) {
    _array.add(element);
  }

  Future<void> cancellAll([bool removeAll = false]) async {
    await Future.wait(map((element) => element.cancel()));

    if (removeAll) clear();
  }

  @override
  void addAll(Iterable<StreamSubscription> iterable) {
    _array.addAll(iterable);
  }

  @override
  void clear() {
    _array.clear();
    super.clear();
  }
}
